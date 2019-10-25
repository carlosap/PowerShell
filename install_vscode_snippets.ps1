write-host "`n  ## VSCODE INSTALLER ## `n"
set-location "$env:APPDATA\Code\User\snippets"
git init .
git remote add origin https://github.com/carlosap/Snippets.git
git pull origin master