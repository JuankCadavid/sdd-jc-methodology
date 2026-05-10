#!/usr/bin/env python3
"""
Verify a Google service account as an owner on Google Search Console
Domain properties via DNS TXT records.

The `gsc` MCP (@mikusnuz/gsc-mcp) does NOT expose Site Verification
endpoints — only Search Console. This helper covers the verification
half: token generation + verify call.

After verification succeeds, use the `gsc` MCP `sites_add` tool to add
the property to Search Console for the service account.

Setup:
  pip install google-auth google-api-python-client

Usage:
  GSC_KEY_PATH=/abs/path/to/service-account.json \
    python3 gsc_verify.py get <domain> [<domain> ...]

  GSC_KEY_PATH=/abs/path/to/service-account.json \
    python3 gsc_verify.py verify <domain> [<domain> ...]

Or pass the key path explicitly:
  python3 gsc_verify.py --key /abs/path/to/key.json get example.com

Workflow:
  1. Run with `get` to obtain a DNS TXT verification token per domain.
  2. Add the TXT record to each domain's DNS (host: @, value: the token).
  3. Wait for DNS propagation (a few minutes to an hour).
  4. Run with `verify` to trigger the verification on Google's side.
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path

try:
    from google.oauth2 import service_account
    from googleapiclient.discovery import build
    from googleapiclient.errors import HttpError
except ImportError:
    print("ERROR: missing dependencies. Install with:", file=sys.stderr)
    print("  pip install google-auth google-api-python-client", file=sys.stderr)
    sys.exit(1)


SCOPES = ["https://www.googleapis.com/auth/siteverification"]


def make_client(key_path: str):
    if not Path(key_path).exists():
        print(f"ERROR: key file not found at: {key_path}", file=sys.stderr)
        sys.exit(1)
    creds = service_account.Credentials.from_service_account_file(
        key_path, scopes=SCOPES
    )
    return build("siteVerification", "v1", credentials=creds, cache_discovery=False)


def get_token(sv, domain: str) -> str:
    body = {
        "site": {"type": "INET_DOMAIN", "identifier": domain},
        "verificationMethod": "DNS_TXT",
    }
    return sv.webResource().getToken(body=body).execute()["token"]


def check_dns(domain: str, token: str):
    """Best-effort check that the TXT record is visible via dig."""
    try:
        out = subprocess.check_output(
            ["dig", "+short", "TXT", domain], stderr=subprocess.DEVNULL, text=True
        )
        return token in out
    except Exception:
        return None


def verify_domain(sv, domain: str):
    body = {"site": {"type": "INET_DOMAIN", "identifier": domain}}
    return sv.webResource().insert(verificationMethod="DNS_TXT", body=body).execute()


def cmd_get(sv, domains):
    print("\n=== DNS TXT records to add ===\n")
    print("For each domain, log into your DNS provider and add a TXT record")
    print("at the root (host = '@' or blank) with the value shown.\n")
    for d in domains:
        try:
            token = get_token(sv, d)
            print(f"--- {d} ---")
            print(f"  Type:  TXT")
            print(f"  Host:  @  (root of {d})")
            print(f"  Value: {token}\n")
        except HttpError as e:
            print(f"--- {d} ---")
            print(f"  ERROR getting token: {e}\n")


def cmd_verify(sv, domains):
    print("\n=== Verifying domains ===\n")
    successes, failures = [], []
    for d in domains:
        try:
            token = get_token(sv, d)
        except HttpError as e:
            print(f"[{d}] ERROR fetching token: {e}")
            failures.append(d)
            continue

        dns_ok = check_dns(d, token)
        if dns_ok is False:
            print(f"[{d}] WARNING: TXT record not visible yet via dig. Trying anyway...")
        elif dns_ok is True:
            print(f"[{d}] TXT record visible in DNS")

        try:
            verify_domain(sv, d)
            print(f"[{d}] VERIFIED — service account is now an owner.")
            successes.append(d)
        except HttpError as e:
            print(f"[{d}] FAILED to verify: {e}")
            failures.append(d)
        print()

    print(f"\nDone. Success: {len(successes)} | Failed: {len(failures)}")
    if failures:
        print("Failed domains:", ", ".join(failures))
        print("Tip: DNS can take a few minutes to propagate. Try again later.")
    return 0 if not failures else 1


def main():
    parser = argparse.ArgumentParser(
        description="Verify a service account as owner on GSC domain properties."
    )
    parser.add_argument(
        "--key",
        default=os.environ.get("GSC_KEY_PATH"),
        help="Path to the Google service account JSON key. "
        "Defaults to $GSC_KEY_PATH.",
    )
    parser.add_argument("action", choices=["get", "verify"])
    parser.add_argument("domains", nargs="+", help="One or more apex domains.")
    args = parser.parse_args()

    if not args.key:
        parser.error(
            "missing service account key: pass --key /abs/path.json or set $GSC_KEY_PATH"
        )

    sv = make_client(args.key)
    if args.action == "get":
        cmd_get(sv, args.domains)
        return 0
    return cmd_verify(sv, args.domains)


if __name__ == "__main__":
    sys.exit(main())
