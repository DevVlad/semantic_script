CURRENT_BRANCH=`git branch | grep \* | cut -d ' ' -f2`
git pull origin $CURRENT_BRANCH
git fetch --tags
LATEST_TAG=`git describe --tags --abbrev=0`;
echo "old tag $LATEST_TAG"
MAJOR=${LATEST_TAG%${LATEST_TAG#*.}}
MAJOR=${MAJOR%?}
LATEST_REV=${LATEST_TAG#*.*.}
MINOR=${LATEST_TAG#*.}
MINOR=${MINOR%${LATEST_REV}}
MINOR=${MINOR%?}
NEW_REV=`git rev-list --all --count`
if [ "$1" = "minor" ]
then
  MINOR=$(($MINOR+1))
  echo "bumping minor version to $MINOR"
fi
if [ "$1" = "major" ]
then
  NEW_REV=0
  MINOR=0
  MAJOR=$(($MAJOR+1))
  echo "bumping major version to $MAJOR"
fi
if [ -z "$MINOR" ]
then
	MINOR=0
fi
if [ -z "$MAJOR" ]
then
	MAJOR=1
fi
APP_VERSION=$MAJOR.$MINOR.$NEW_REV
echo "new tag $APP_VERSION"
if [ $APP_VERSION = $LATEST_TAG ]
then
	echo "No changes on found"
	exit;
fi
read -p "Push new git tag? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    git tag -a $APP_VERSION -m ""
    git push origin $CURRENT_BRANCH $APP_VERSION
    #write nice git log to new file and concatenate with old file
    { echo "v$APP_VERSION - $(date) $(ls -1 | wc -l)"; git log --merges --pretty=oneline "$LATEST_TAG...$APP_VERSION" | grep pull; echo ""; cat CHANGELOG.md; } >> CHANGELOG.new
    mv CHANGELOG{.new,.md}
    git add .
    git commit -m "submitting changelog $(date) $(ls -1 | wc -l)"
    git push origin $CURRENT_BRANCH
fi