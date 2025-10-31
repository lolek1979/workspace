# .NET update process

## Preface

.NET update process is triggered by minor updates of the current .NET framework version in use.
This process is optional for minor updates without security fixes and mandatory for minor
updates with security fixes.

## Servicing updates
Servicing updates (patches) ship almost every month, and these updates carry both security and 
non-security bug fixes. For example, .NET 9.0.8 was the eighth update for .NET 9. When these updates 
include security fixes, they're released on "patch Tuesday", which is always the second Tuesday of 
the month. Servicing updates are expected to maintain compatibility. Having two different servicing 
updates on very same machine is unsuported scenario.

![Security fix mark](../assets/net-servicing-security-mark.png)

## Step by step guide

Following chapter describes step by step guide how update .NET runtime and SDK on developer's 
machine.
