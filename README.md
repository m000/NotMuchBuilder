# NotMuch Builder

This is a mirror of the NotMuch code from the [original website][notmuch-www].
The aim is to streamline building a minimal version of NotMuch for Ubuntu.
A [Docker][docker-www] container is included to facilitate the builds.

The parts of the package related to Emacs and Ruby have been disabled.

Pull requests to improve this process are welcome. Pull requests related
to the software itself will be ignored.

## Usage
Builds use the currently checked out version of the source code:

```bash
docker build . -t notmuch
docker run --name notmuch.build notmuch
docker cp notmuch.build:/usr/src/notmuch.out .
```

Then, you can install the produced deb packages. If any dependencies
are not met, let apt handle them:

```bash
sudo dpkg -i notmuch.out/*.deb
sudo apt-get update --fix-missing
sudo apt-get install -f
```

If you want to use the changes and the Dockerfile from the master branch
of NotMuch Builder on another branch, you can apply them with:

```bash
git cherry-pick upstream/master..master
```

[notmuch-www]: https://notmuchmail.org
[docker-www]: https://www.docker.com/
