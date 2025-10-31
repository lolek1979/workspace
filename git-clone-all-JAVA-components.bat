@echo off
setlocal enabledelayedexpansion

:: list of JAVA components repo
set repos[0]=https://vzp@dev.azure.com/vzp/NIS/_git/component-java-cip-audit
set repos[1]=https://vzp@dev.azure.com/vzp/NIS/_git/component-java-cip-dwh
set repos[2]=https://vzp@dev.azure.com/vzp/NIS/_git/component-java-cip-kafka-appender
set repos[3]=https://vzp@dev.azure.com/vzp/NIS/_git/component-java-cip-logs
set repos[4]=https://vzp@dev.azure.com/vzp/NIS/_git/component-java-cip-tools-kafka-messenger-sender
set repos[5]=https://vzp@dev.azure.com/vzp/NIS/_git/component-java-cip-audit-ui
set repos[6]=https://vzp@dev.azure.com/vzp/NIS/_git/component-java-bus-gov
set repos[7]=https://vzp@dev.azure.com/vzp/NIS/_git/java-shared-framework

set count=8

:: loop to clone all JAVA repos
for /l %%i in (0,1,%count%) do (
    call set repo=%%repos[%%i]%%
    if defined repo (
        echo Cloning !repo! ...
        git clone !repo!
    )
)

echo Done.
pause
