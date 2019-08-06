echo "List of existing branches "
git branch 
echo -n "Enter branch name > "
read BRANCH_NAME
git pull origin $BRANCH_NAME
git add -A .
echo -n "Enter comment > "
read COMMENT
git commit -m "$COMMENT"
TAG_NAME=$BRANCH_NAME-$(TZ=":US/Eastern" date +%Y%m%d%H%M)
git tag $TAG_NAME
echo "*************GIT PUSH TO TAG : $TAG_NAME **************"
git push origin $TAG_NAME
echo "*************GIT PUSH TO BRANCH : $BRANCH_NAME*********"
git push origin $BRANCH_NAME
