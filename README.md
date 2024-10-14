# JuliaDelft24

A four-day course that will take place at [TU Delft](https://www.tudelft.nl/en/) in October 2024.
   
**Trainer:** [Dr. Carsten Bauer](https://github.com/carstenbauer)

**Course page:** https://www.tudelft.nl/en/evenementen/2024/dcse/courses/introduction-to-julia-for-high-performance-computing

## Schedule (tentative)

<a href="https://github.com/carstenbauer/JuliaDelft24/raw/main/orga/timetable.pdf"><img src="https://github.com/carstenbauer/JuliaDelft24/raw/main/orga/timetable.png" width=720px></a>

## Preparing for the course

<details>
   <summary> <h2>Preparing your laptop (click to unfold)</h2> </summary>

### Install Julia 1.10

The simplest way to install Julia 1.10 is via [juliaup](https://github.com/JuliaLang/juliaup). Run one of the following in a terminal.

##### Linux/macOS

```
curl -fsSL https://install.julialang.org | sh -s -- --yes --default-channel 1.10
```

##### Windows

```
winget install julia -s msstore
```

**Important:** Julia 1.11 has been released on Oct 8 but for the course we'll still use 1.10. Make sure that you have the correct Julia version! To do so with `juliaup` you can run the following commands:

```
juliaup add 1.10
juliaup default 1.10
```

### Download workshop materials

The simplest way to download the workshop materials (this GitHub repository) is through [Git]().

```bash
git clone https://github.com/carstenbauer/JuliaDelft24
```

If you don't have Git, you can either [install it](https://github.com/git-guides/install-git) or manually [download the materials as a `.zip` archive](https://github.com/carstenbauer/JuliaDelft24/archive/refs/heads/main.zip) instead.

### Installing the Julia environment

Within the `JuliaDelft24` directory (that you've cloned or downloaded above), run the following command:

```bash
julia install.jl
```

**Remark: The installation might take a couple of minutes and a few GB of disk space** (worst case: up to ~10 minutes and up to ~2.6 GB). The reason is that we also install binary dependencies (e.g. MPI) via Julia's Package manager to be as self-contained as possible. If you want to remove everything after the course, simply delete `~/.julia`.

### Update `PATH` environment variable

We will use `mpiexecjl` during the course, which - after the installation above - lies in `~/.julia/bin`. To make it available everywhere, we need to add `~/.julia/bin` to the `PATH` environment variable. On Linux/macOS, you can add the following line to your `.bashrc` (or whatever file gets automatically loaded by your shell):

```
export PATH=$HOME/.julia/bin:$PATH
```

I don't have Windows, and don't know how to do it there, but you should readily find instructions on Google.

### Install Visual Studio Code (+ extensions)

* Download Visual Studio Code from https://code.visualstudio.com/download and install it.
* Afterwards, install the following two extensions (the linked pages should have "Install" buttons, respectively)
  * [Remote - SSH extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
  * [Julia extension](https://marketplace.visualstudio.com/items?itemName=julialang.language-julia)

### Install Jupyter Lab

Technically, you don't necessarily need Jupyter Lab, because Visual Studio Code can also open notebook files. However, I highly recommend that you install it:

* [Installation instructions](https://jupyter.org/install)

If you don't manage to install Jupyter using the above link, you can also let Julia try to install it for you. Run `julia --project` **within the `JuliaDelft24` directory** and then execute the following Julia commands:

```julia
using IJulia
IJulia.notebook()
```
</details>

<details>
   <summary> <h2>Preparing your DelftBlue account (click to unfold)</h2> </summary>

### Login

Anyone with a TU Delft NetID should be able to SSH to DelftBlue. You can use a terminal or Visual Studio Code to login to the cluster. If necessary, more details are available in the DelftBlue documentation [here](https://doc.dhpc.tudelft.nl/delftblue/Remote-access-to-DelftBlue/#ssh).

##### Terminal

Open a terminal and login to the cluster with the following command (where your replace `<netid>` by your NetID).

```
ssh <netid>@login.delftblue.tudelft.nl
```

##### VS Code

1. Open Visual Studio Code.
2. Press `CTRL + SHIFT + P` or `CMD + SHIFT + P` (opens a popup menu) and type and select `Remote-SSH: Connect to Host...`.
3. When asked for it, input `<netid>login.delftblue.tudelft.nl` for the hostname (with `<netid>` replaced by your NetID) and press `Enter`.

After some time, you should have VS Code running on the cluster. You can get an integrated terminal by pressing `CTRL + SHIFT + P` or `CMD + SHIFT + P` and running `Terminal: Create New Terminal`.

### Setting things up

Execute the following command on the cluster

```
sh /projects/julia/setup_account.sh
```

You only have to do this once. If you're curious, the script will

* put a single line at the end of your `~/.bashrc`,
* clone the workshop materials to `/scratch/<netid>/JuliaDelft24`.

(Easy to undo after the course, if you like to.)

</details>
