@echo off
echo [1/3] Cleaning and Generating...
call hexo clean
call hexo g

echo [2/3] Deploying to Website (HTML)...
call hexo d

echo [3/3] Backing up Source Code (Git)...
git add .
git commit -m "Auto backup: %date% %time%"
git push origin hexo

echo ===========================================
echo  All Done! Vodka Blog is safe and updated.
echo ===========================================
pause