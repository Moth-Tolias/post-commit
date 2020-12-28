post-commit: a git hook for posting about commits
=========

uses only the D standard library.

## how to use
 * compile
 * place the result in the .git/hooks folder of whatever (local) repository you want to send messages from
 * make sure the executable is named "post-commit", or git won't run it!
 * make a file called "webhooks.txt" containing a list of all the urls you want to post to (one url per line)
	* if you're posting to discord: make a webhook, if you haven't already, and put the url in webhooks.txt
 * place webhooks.txt in the same folder as post-commit
 * make a commit!

at the time of this writing, only discord-style posting is supported.

