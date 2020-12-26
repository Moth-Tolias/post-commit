/*
 * post-commit - a git hook to send the commit message to a discord webhook
 * Copyright (C) 2020  Susan Tootill
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

string getLastCommitString()
{
	enum string format = `"%h %an: %s%n%-b"`;
	import std.process;
	immutable auto result = executeShell("git log -1 HEAD --pretty=format:" ~ format);
    return result[1];
}

string[] getURLs(const string path)
{
	string[] result;

	import std.stdio;
	auto f = File(path, "r");

	import std.string;
	while (!f.eof())
	{
		string line = strip(f.readln());
		if (line != "") //don't add empty lines
		{
			result ~= line;
		}
	}

	return result;
}

/// send message to url
/// i dunno why the lint complains about this one being
/// undocumented yet not the others, but ok
bool sendMessage(const string url)
{
	import std.net.curl;
	auto http = HTTP(url);

	import std.string;
	immutable string lastCommit = replace(getLastCommitString(), "\n", r"\n");
	immutable string data = `{"content":"` ~ lastCommit ~ `"}`;
	immutable string mimeType = "application/json";

	http.setPostData(data, mimeType);
	http.perform();

	return true; //TODO: error detection
}

int main()
{
	import std.stdio;
	import std.file;
	import std.path;

	immutable string path = dirName(thisExePath()) ~ "/webhooks.txt";
	if (!path.exists)
	{
		writeln(`to use, rename to "post-commit" and place in .git/hooks alongside webhooks.txt`);
		return 1;
	}

	// i don't know why this doesn't let me define it as immutable
	const auto urls = getURLs(path);

	foreach(string url; urls)
	{
		if (!sendMessage(url))
		{
			return 1; //something has gone wrong
		}
	}


	writeln("message sent! ♥");
	return 1; //all good
}
