# Take an XML backup sans attachments, move them into the jira_anon folder once the rest of this is ready to go
wget https://confluence.atlassian.com/download/attachments/12079/atlassian-xml-cleaner-0.1.jar?version=1
 
mv atlassian-xml-cleaner-0.1.jar\?version\=1  atlassian-xml-cleaner-0.1.jar
 
wget https://confluence.atlassian.com/download/attachments/139008/jira_anon.zip?version=1&modificationDate=1367988226752&api=v2
 
mv jira_anon.zip\?version\=1 jira_anon.zip
unzip jira_anon.zip ; rm -f jira_anon.zip ; mv atlassian-xml-cleaner-0.1.jar jira_anon/ ; cd jira_anon/
 
# Move in your xml backup, unzip it, hit it with the following
 
# Clean it
java -jar atlassian-xml-cleaner-0.1.jar entities.xml > entities-clean.xml
# Anonymize it
java -Xmx512m -jar joost.jar entities-clean.xml anon.stx > anon-jira-backup.xml
mkdir anon-backup
mv anon-jira-backup.xml anon-backup/ ; mv activeobjects.xml anon-backup/
# Tar it back up
tar -zcvf $YOUR_FILE.tar.gz anon-backup/
