
FILENAME=$1

echo ${FILENAME}

# modifiers
sed -i '' 's/post_title/title/' ${FILENAME}
sed -i '' 's/post_date/date/' ${FILENAME}
sed -i '' 's/url: /slug: /' ${FILENAME}

# removals
sed -i '' 's/ID: .*$//' ${FILENAME}
sed -i '' 's/post_excerpt.*//' ${FILENAME}
sed -i '' 's/published:.*//' ${FILENAME}

# slug
sed -i '' 's/permalink: >.*//' ${FILENAME}
sed -i '' 's/^  https:\/\/www.yourtech.us\/20..\//url: /' ${FILENAME}


