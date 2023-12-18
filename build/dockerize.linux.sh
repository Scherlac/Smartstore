
cd ..
#docker build --target runtime -t scherlac/smartstore-runtime:latest .
find . -iregex '.*\.\(csproj\|props\|targets\)' | tar -cvzf proj.tgz -T -
docker build -t scherlac/smartstore-linux:latest .
echo 'Press enter to exit...'; read dummy;
