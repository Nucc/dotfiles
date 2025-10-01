#!/bin/bash

set -x  # Enable debug mode

# Cache file for GitHub repositories
CACHE_FILE="$HOME/Code/.github-repos-cache"
TEMP_FILE=$(mktemp)

echo "DEBUG: CACHE_FILE=$CACHE_FILE"
echo "DEBUG: TEMP_FILE=$TEMP_FILE"
echo ""
echo "Fetching all GitHub repositories..."
echo "This may take several minutes (zendesk has ~10k repos)..."
echo ""

# Fetch personal repos
echo "Fetching personal repositories..."
echo "DEBUG: Running: gh api --paginate 'user/repos?per_page=100' --jq '.[].full_name'"
gh api --paginate 'user/repos?per_page=100' --jq '.[].full_name' > "$TEMP_FILE.personal" 2>&1 &
PERSONAL_PID=$!
echo "DEBUG: Personal PID=$PERSONAL_PID"

# Fetch zendesk org repos in background
echo "Fetching zendesk organization repositories (this will take a while)..."
echo "DEBUG: Running: gh api --paginate 'orgs/zendesk/repos?per_page=100' --jq '.[].full_name'"
gh api --paginate 'orgs/zendesk/repos?per_page=100' --jq '.[].full_name' > "$TEMP_FILE.zendesk" 2>&1 &
ZENDESK_PID=$!
echo "DEBUG: Zendesk PID=$ZENDESK_PID"

# Wait for personal repos (should be quick)
echo "DEBUG: Waiting for personal repos..."
wait $PERSONAL_PID
PERSONAL_EXIT=$?
echo "DEBUG: Personal repos exit code: $PERSONAL_EXIT"
echo "DEBUG: Personal file exists: $(test -f "$TEMP_FILE.personal" && echo yes || echo no)"
echo "DEBUG: Personal file size: $(wc -l < "$TEMP_FILE.personal" 2>/dev/null || echo 0)"
echo "DEBUG: First 5 lines of personal file:"
head -5 "$TEMP_FILE.personal" 2>&1

personal_count=$(wc -l < "$TEMP_FILE.personal" 2>/dev/null | tr -d ' ')
echo "  ✓ Fetched $personal_count personal repos"

# Show progress while waiting for zendesk
echo -n "  Waiting for zendesk repos"
while kill -0 $ZENDESK_PID 2>/dev/null; do
  echo -n "."
  # Show current size
  current=$(wc -l < "$TEMP_FILE.zendesk" 2>/dev/null | tr -d ' ')
  echo -n "[$current]"
  sleep 2
done
wait $ZENDESK_PID
ZENDESK_EXIT=$?
echo ""
echo "DEBUG: Zendesk repos exit code: $ZENDESK_EXIT"
echo "DEBUG: Zendesk file exists: $(test -f "$TEMP_FILE.zendesk" && echo yes || echo no)"
echo "DEBUG: Zendesk file size: $(wc -l < "$TEMP_FILE.zendesk" 2>/dev/null || echo 0)"
echo "DEBUG: First 5 lines of zendesk file:"
head -5 "$TEMP_FILE.zendesk" 2>&1

zendesk_count=$(wc -l < "$TEMP_FILE.zendesk" 2>/dev/null | tr -d ' ')
echo "  ✓ Fetched $zendesk_count zendesk repos"

# Combine results
echo "DEBUG: Combining results into $TEMP_FILE"
cat "$TEMP_FILE.personal" "$TEMP_FILE.zendesk" >> "$TEMP_FILE" 2>/dev/null
echo "DEBUG: Combined file size: $(wc -l < "$TEMP_FILE" 2>/dev/null || echo 0)"
rm -f "$TEMP_FILE.personal" "$TEMP_FILE.zendesk"

NEW_REPOS=$(cat "$TEMP_FILE" | sort -u)
echo "DEBUG: Unique repos count: $(echo "$NEW_REPOS" | wc -l | tr -d ' ')"
rm -f "$TEMP_FILE"

# Merge with existing cache (append new ones)
if [ -n "$NEW_REPOS" ]; then
  echo "DEBUG: Writing to cache file"
  {
    cat "$CACHE_FILE" 2>/dev/null
    echo "$NEW_REPOS"
  } | sort -u > "$CACHE_FILE.tmp"

  echo "DEBUG: Cache tmp file size: $(wc -l < "$CACHE_FILE.tmp" 2>/dev/null || echo 0)"
  mv "$CACHE_FILE.tmp" "$CACHE_FILE"
  echo "DEBUG: Final cache file exists: $(test -f "$CACHE_FILE" && echo yes || echo no)"

  TOTAL=$(wc -l < "$CACHE_FILE" | tr -d ' ')
  echo ""
  echo "✓ Cache updated successfully!"
  echo "Total repositories in cache: $TOTAL"
  echo "Cache location: $CACHE_FILE"
else
  echo "ERROR: No repositories found"
fi
