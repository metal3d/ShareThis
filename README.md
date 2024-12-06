# ShareThis directory as WebDav without hassle

No password, no login, no registration, no configuratio, only share this directory.

For **Podman** users! I never tried it with Docker... It needs `keep-id` user namespace option to work properly.

## How to test?

```bash
mkdir -p /tmp/test-webdav
podman run -v /tmp/test-webdav:/data/www:Z -p 8088:80 --rm ghcr.io/metal3d/sharethis:main
# then open a dav://localhost:8088/ on Gnome file manager
```

You must be able to copy files in the `/tmp/test-webdav` directory or inside the dav://localhost:8088/ directory.
You also must be able to see the content from outside, using your IP or computer name instead of localhost.

Then `Ctrl+C` to stop the container. And install the service (see below).

## How to really install?

Copy the "`webdav.container`" file inside `~/.config/containers/sytemd/` directory.

```bash
mkdir -p ~/.config/containers/sytemd/
curl -sSL https://raw.githubusercontent.com/metal3d/ShareThis/main/webdav.container -O ~/.config/containers/sytemd/webdav.container
# you can edit the file to change the port, or the image version
# then...
systemctl --user daemon-reload
systemctl --user start webdav
```

> I **strongly** recommend using this as non-root user.

You should now have a running WebDav server on port 8088.

```bash
$ systemctl --user status webdav
● webdav.service - WebDav share service
     Loaded: loaded (/home/.../.config/containers/systemd/webdav.container; generated)
    Drop-In: /usr/lib/systemd/user/service.d
             └─10-timeout-abort.conf
             /run/user/1000/systemd/user.control/webdav.service.d
             └─50-CPUWeight.conf, 50-IOWeight.conf
     Active: active (running) since Fri 2024-12-06 00:25:01 CET; 13min ago
#...
$ podman ps | grep -o "webdav-.*"
webdav-sharethis
```

Now, go to Gnome file manager (Nautilus) and type `dav://localhost:8088` in the location bar. You should see the content
of your home 'Public' directory.

Copying files in this directory will make them accessible through the WebDav server. And vice versa.

## Why not using the "share" feature of Gnome?

You can, if you only use Linux on your local network, it's great.

But... If you need to share files with Windows, macOS, or even with your phone, it's not so easy:

- It changes port each time you start sharing, or if you restart your computer
- It makes very complicated to access the shared directory from another computer, especially on Windows...
- It's easy with a Podman image, and the
fantastic [Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) feature.

**So I made this simple WebDav server.**

## What's inside?

Nothing very special, it's a simple `httpd` (Apache2) server with the `webdav` module enabled. The configuration is
very simple:

- Apache `httpd` server
- WebDav modules
- some other modules to allow access to the directory
- a declared volume
- changing the port to 8080 to allow running without root
- See the [Dockerfile](https://github.com/metal3d/ShareThis/blob/main/Dockerfile) content
and the [httpd.conf](https://github.com/metal3d/ShareThis/blob/main/conf/httpd.conf) content.

## Some notes about the container and the versions

- The "latest" branch is packaged in the registry on each release. So the ":latest" tag is always up-to-date and related
to the "stable" version (the latest tag).
- Because the "`AutoUpdate`" directive is set to `registry`, the container is updated on each start. You can change this
behavior, see below.
- A release is created on each "main" update, so you can change the image tag to "`:main`" to be on bleeding edge version.
- Or, of course, you may specify a fixed version like "v1.0.0" to keep a working version without any surprise.

> **Each time you want to change the file in `~/.config/containers/sytemd/` directory, you need to run the `systemctl --user
daermon-reload` command.**

## How to uninstall?

To remove the service:

- `systemctl --user stop webdav`
- just delete the `webdav.container` file in `~/.config/containers/sytemd/` directory
- `systemctl --user daemon-reload`
