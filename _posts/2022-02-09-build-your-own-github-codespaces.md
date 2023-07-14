---
title: "Build Your Own GitHub Codespaces With the Windows OpenSSH Server"
author: Ryan Young
categories:
  - tech
---

GitHub recently made Codespaces available to every GitHub user, and they've been getting rave reviews. Like a digital petting zoo in the cloud, a Codespace is a virtual machine built just for programming that you can access through any ordinary web browser. Code on your ultrabook, your iPad, even your phone; it's easy to see the appeal. The promise of Codespaces is the promise of game streaming--work or play from any device, anytime, anywhere.

But why should you have to rent a computer from GitHub to get any work done? Didn't you just drop $2000, plus Windows license, on that hexacore, liquid-cooled ultimate gaming rig sitting on top of your desk? And you're *still* going to swipe your credit card for every hour you spend staring blankly at your rented GitHub terminal? Boy, don't you feel like a chump. Your desktop computer is equipped with all the resources you need to program, and then some; the only catch is that you need to be physically at your desk--or put up with the clumsiness of a remote desktop session--to make use of them.

{% include figure.html image="https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Gaming_computers_%281%29.jpg/1280px-Gaming_computers_%281%29.jpg" alt="Gaming computers on a Las Vegas showfloor." width="1280" height="853" caption="Only the best will do to browse Google Chrome and play indie sidescroller games! 4K, 60FPS! (Credit: [Notdjey, Wikimedia](https://commons.wikimedia.org/wiki/File:Gaming_computers_(1).jpg))" captionmarkdown="true" %}

Well, what if you could turn your gaming setup into your own personal Codespaces host? Thanks to a slate of Microsoft's newest toys, it can be done!

On your monster gaming rig, the stack includes:
- Windows Subsystem for Linux
- Docker for Linux
- Windows OpenSSH server

On your lightweight Windows/Linux/macOS PC of choice:
- Visual Studio Code
- Remote SSH extension
- Dev Containers extension

Basically, you write your code in Visual Studio Code. Code uses the development containers extension to connect to a container running inside a Docker daemon. The Docker daemon runs inside of Windows Subsystem for Linux, which is itself just a fancy name for a virtual machine. Why run Linux inside WSL? Well, if you value your time spent troubleshooting complicated compatibility technologies like Wine, Proton, or VFIO above *zero*, you should already be booting Windows bare metal to play games. Phoronix recently [clocked](https://www.phoronix.com/review/windows11-wsl2-good) WSL at about 94% of the speed of a native Ubuntu install, so with WSL you're sacrificing very little performance, while gaining a whole lot of convenience.

To run Docker on WSL, I opt for the headless Docker Engine daemon over Docker Desktop. The special Linux distribution that comes with Docker Desktop isn't meant to be interacted with outside of the GUI, so it's far more logical to SSH into a standard Linux installation that accepts ordinary shell commands. (Some people also have a problem with Docker Desktop's new freemium model, which using Docker Engine neatly bypasses.) If you're still interested in a GUI, Visual Studio Code's [Docker extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) is a worthy substitute for Docker Desktop's niceties.

## Step 1: Linux setup with Windows Subsystem for Linux

As of 2023, WSL is now distributed via the Microsoft Store, but installing WSL that way breaks compatibility with the OpenSSH server, among other things. It's a [known bug](https://github.com/microsoft/WSL/issues/9231), and Microsoft is working on a fix. In the meantime, you should [install](https://devblogs.microsoft.com/commandline/the-windows-subsystem-for-linux-in-the-microsoft-store-is-now-generally-available-on-windows-10-and-11/#the-store-version-of-wsl-is-now-the-default-version-of-wsl) WSL using the Windows component instead:

```
> wsl.exe --install --inbox
```

I recommend [Debian](https://apps.microsoft.com/store/detail/debian/9MSVKQC78PK6) as your WSL distribution of choice. It's officially supported and has fewer moving parts than Ubuntu, the next best alternative. Once you have your Debian installation up and running, simply follow the official [instructions](https://docs.docker.com/engine/install/debian/) to install Docker Engine. One gotcha is that Docker Engine's default nftables backend is currently [broken](https://github.com/docker/for-linux/issues/1406) on WSL, so you'll have to switch to the iptables-legacy backend with:

```
# update-alternatives --config iptables
```

WSL does not include systemd, so services do not autostart. To start Docker Engine at boot, you'll have to create a new file at `/etc/wsl.conf` with the following contents:

```ini
[boot]
command = service docker start
```

## Step 2: OpenSSH server setup

Windows now ships with an optional OpenSSH server. (Never did I imagine I would ever write that sentence.) We can use that server to facilitate remote access to the WSL virtual machine. Trust me--this method is far easier than the alternative, which is to run an SSH server inside the VM and somehow instruct Windows to forward traffic to it (IP addresses aren't stable in WSL), a mad act that Scott Hanselman has compared to "trying to ice skate up hill."

Start by [enabling](https://www.hanselman.com/blog/the-easy-way-how-to-ssh-into-bash-and-wsl2-on-windows-10-from-an-external-machine) the OpenSSH server and [setting](https://www.hanselman.com/blog/the-easy-way-how-to-ssh-into-bash-and-wsl2-on-windows-10-from-an-external-machine) the default shell to WSL2. Now, you can point your SSH client at your Windows desktop on port 22, and you'll get a Bash shell inside your WSL instance! If you are a Windows administrator (as you probably are), you should insert your public keys into the file at `C:\ProgramData\ssh\administrators_authorized_keys`.

Finally, you'll have to make port 22 on your Windows desktop reachable from the Internet. How you do this depends, of course, on your own networking setup. Personally, I'm fortunate enough to receive native IPv6 connectivity at home, so I simply open a pinhole in my firewall and populate an AAAA record for my desktop. If I need to connect from a location that doesn't support IPv6, or that blocks SSH connections, I tunnel my traffic through my trusty Mozilla VPN app, which is one of the few VPN products that supports IPv6.

## Step 3: Visual Studio Code setup

Install Visual Studio Code on your PC of choice and install the [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) and [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extensions. Use the "Remote-SSH: Connect to Host" command to initiate an SSH connection to your Windows desktop.

On your very first attempt, you'll likely receive a broken pipe error--when Visual Studio Code encounters a Windows SSH server, it expects a PowerShell prompt, not Bash. To fix this, [use](https://code.visualstudio.com/docs/remote/ssh#_connect-to-a-remote-host) the `remote.SSH.remotePlatform` preference to map your Windows desktop's hostname to "Linux".

You'll also have to set the `remote.SSH.localServerDownload` preference to "off", and install curl or wget inside your WSL machine. By default, Visual Studio Code attempts to copy resources to the remote host via scp, which will fail with this configuration, since the Windows OpenSSH server only provides dumb shell access.

Once you've successfully established an SSH connection to the WSL machine, Visual Studio Code lets you browse files and run shell commands on it. You can even browse the Windows filesystem through the `/mnt/c` directory and, if you have the Docker extension installed, interact with the Docker daemon. But the real magic happens with the Dev Container extension--navigate to a directory with a `.devcontainer/devcontainer.json` definition, and Visual Studio Code will offer you the option to spin up and enter a development container, all over SSH.

## Step 4: Done!

And there we have it. You get the killer features of GitHub Codespaces--templated environments, dedicated hardware, and remote access from anywhere on the Internet--for free, using a computer you probably already own.

The major downside of this setup is that you must use the *desktop* version of Visual Studio Code on the client, which means that client must be running an officially supported version of Windows, Linux, or macOS. (Sorry--no iPads, Chromebooks, or smart refrigerators.) As of 2023, the remote development extensions cannot be used with [VSCode.dev](https://code.visualstudio.com/blogs/2021/10/20/vscode-dev), nor with the official [Visual Studio Code Server](https://code.visualstudio.com/docs/remote/vscode-server), nor with open-source derivatives like VSCodium, so for the moment, you have no real alternative here.

But for me, that's an insignificant price to pay for such a powerful, yet convenient, programming experience. My current laptop for on-the-go computing is a Lenovo Yoga Flex, which I really like; it's thin, light, and quiet, and it gets amazing battery life. But like every laptop, it would not be so quiet or long-lasting if I instructed it to compile a very large codebase, or execute a very long test suite. Development containers hosted on my desktop give me the best of both worlds: a powerful mothership to work on and a comfortable client to type into. And since my laptop need only be a glorified netbook capable of running an Electron app, as opposed to a monster machine that can drag race its way through a few thousand unit tests, I'm free to skimp on my next laptop purchase, redirecting the savings toward my desktop for the best programming-plus-gaming machine for my dollar.

I cannot stress how brilliant development containers are as a concept. They give me the power to switch between programming stacks at the push of a button--from Python 3 for maintaining Mailrise, to Python 2 for contributing patches to Apprise, to Node/TypeScript for working on TypeScriptToLua. Instead of burning hours setting up the Linux tooling for each context switch, I can check out, test, and ship a new PR in under an hour, which is exactly the kind of efficiency I need to be productive on the run.

The experience remains impressively good over a mobile data connection, too--say, while on a city bus--thanks in large part to Visual Studio Code's predictive terminal echoing, a feature that anticipates the characters that should appear on your terminal before they actually get transmitted back by the remote host. And since the remote connection consists primarily of shell commands, it doesn't use that much data, either! I count just a couple of megabytes per hour of work.

Given all these advantages, it's no wonder GitHub [migrated](https://github.blog/2021-08-11-githubs-engineering-team-moved-codespaces/) all their engineering teams to Codespaces. If you use Visual Studio Code as your IDE and your projects fit into development containers, it's a no-brainer for you, too. And with my way, you won't owe GitHub a cent, or a credit card number.