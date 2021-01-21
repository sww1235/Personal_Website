<h1 id="top">GnuPG Configuration and Setup</h1>

This is documentation around how I have setup my GnuPG keys, across multiple
operating systems, so I don't forget and have to do a bunch of research over
again.


<h2 id="generating-keys">Generating Keys</h2>

1.	Install GnuPG package for your operating system. See Operating System
	specific sections below.

2.	Run `gnu --full-gen-key` to generate a public-private OpenPGP compatible
	keypair. Answer prompts as follows:

	1.	Answer `RSA and RSA` which is the default.
	2.	4096 bit key.
	3.	4y
	4.	Enter legal name
	5.	Enter domain@domain email for main identity
	6.	Comment can be left blank
	7.	Verify info and hit `O` for Ok
	8.	Enter a strong passphrase. Use password vault to generate.

3.	Generate revocation certificate as well.

	```sh
	gpg --list-keys
	# note your key id
	# now generate certificate with that key id
	gpg --armor --gen-revoke [your key ID] > pgp-revocation.asc
	```


Now make sure to [backup](#backing-up-keys) and [manage](#managing-keys) your keys as follows.

<h2 id="backing-up-keys">Backing Up Keys</h2>

1.	Export ASCII armored version of public keys: `gpg --armor --export >
	pgp-public-keys.asc`

2.	Export ASCII armored version of private keys: `gpg --armor
	--export-secret-keys > pgp-private-keys.asc`

3.	Export owner-trust certificate: `gpg --export-ownertrust >
	pgp-ownertrust.asc`

4.	Print, using a OCR font, these 3 generated files as well as your revocation
	certificate and store them in a safe place. Current best method to print
	the files is:

	1.	copy the OCR-A font files into `~/.fonts/`.

	2.	run `mkafmmap` in `~/.fonts/` to generate the font map file.

	3.	create `~/.enscriptrc`, with contents of `AFMPath:
		/usr/share/enscript/afm:/usr/local/lib/ps:/usr/lib/ps:/home/toxicsauce/.fonts`.
		Essentially take the `AFMPath` from `/etc/enscript.cfg` and add your
		homedir font dir to the end.
	
	4.	Run `enscript -f OCR-A10 <file>` to print public, private, ownertrust,
		and revocation files, then store them in a safe location, preferably a
		fireproof safe.

Enscript reference: <https://east.fm/posts/adding-fonts-to-enscript/index.html>


<h2 id="managing-keys">Managing Keys</h2>

<h3 id="restoring-backups">Restoring Backed Up Keys</h3>

1.	Scan and OCR your pages (or enter them by hand)

2.	Enter the following commands to restore from the files you created:

	```sh
	gpg --import pgp-public-keys.asc
	gpg --import pgp-private-keys.asc
	gpg --import-ownertrust pgp-ownertrust.asc
	```

<h3 id="revoking-keys">Revoking keys</h3>

To revoke a compromised key, run the following command, and upload to any
public keyservers. Also generate new keys imediately.

	```sh
	gpg --import pgp-revocation.asc
	```

<h3 id="renewing-keys">Renewing Keys</h3>

When your keypair expires, you can renew it instead of creating a new keypair.

1.	`gpg --list-keys` and record the keyid you want to rewew.
2.	`gpg --edit-key [your key ID]`
3.	`Command: expire`
4.	Enter new expiration time.
5.	`Command: save` to save changes to key. Make sure to push to keyservers.

<h3 id="copying-keys">Copying Keys To Another Computer</h3>

Easiest way is to use scp. `scp -r ~/.gnupg user@remotehost:~/`



<h2 id="os-specific">Operating System Specific Instructions</h2>

<h3 id="freebsd">FreeBSD</h3>

Copied from the [FreeBSD Handbook](https://www.freebsd.org/doc/en/articles/committers-guide/pgpkeys.html)

1.	Install `security/gnupg` from packages. this is gpg2

2.	Set preferences in `~/.gnupg/gpg.conf`

<h3 id="void-linux">Void Linux</h3>

1.	Install `gnupg2`
2.	Set preferences in `~/.gnupg/gpg.conf`


<h2 id="references">References</h2>

-	<https://msol.io/blog/tech/back-up-your-pgp-keys-with-gpg/>
-	<https://tech.michaelaltfield.net/2009/02/05/new-gpg-key/>

```tags
GnuPG, PGP, GPG, Security
```
