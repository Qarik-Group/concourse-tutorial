#!/bin/sh

set -eu

# $RANDOM returns a different random integer at each invocation.
# Nominal range: 0 - 32767 (signed 16-bit integer).

# This script will succeed (exit 0) 50% of the time
value=$RANDOM
if [[ $value -gt 16384 ]]; then
  cat > notify_message/message <<EOF
Unfortunately the \`test\` job failed. The random value $value needed to be less than 16384 to succeed.
EOF
  exit 1
else
  cat > notify_message/message <<EOF
Hurray! The \`test\` job succeeded. The random value $value needed to be less than 16384 to succeed.
EOF
  exit 0
fi
