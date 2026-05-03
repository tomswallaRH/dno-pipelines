#!/usr/bin/env python3
"""Emit participant emails for automation (space-separated tokens)."""

import os


def main() -> None:
    default = "sfathii@redhat.com"
    line = os.environ.get("RECIPIENT_EMAILS", default).strip()
    print(line)


if __name__ == "__main__":
    main()
