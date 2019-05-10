# windows_security
Random scripts you can use to harden Windows machines.

# ignorer.ps1
There is a devastating attack chain that leverages weak name resolution protocols and weak SMB configurations to steal credentials and gain remote access to machines on a network. [This blog outlines the process nicely](https://byt3bl33d3r.github.io/practical-guide-to-ntlm-relaying-in-2017-aka-getting-a-foothold-in-under-5-minutes.html).

ignorer.ps1 will neuter this attack chain by disabling SMBv1, forcing SMB signing, disabling LLMNR and disabling NTB-NS on Windows machines.
