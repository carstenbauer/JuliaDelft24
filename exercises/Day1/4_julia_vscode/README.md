# Exercise: The Julia VSCode extension

## Getting started

1. Open VS Code.
2. In VS Code, open the workshop directory by pressing `CTRL + O` or `CMD + O` and selecting the workshop folder.

Imagine you would like to start working *interactively* with Julia now. One option you have is to do the following:

3. Open a terminal by either
  - pressing `CTRL + ~` (or `CMD + ~` on macOS) or
  - pressing `CTRL + Shift + P` (or `CMD + Shift + P`) and typing and selecting `Terminal: Create New Terminal`.
4. In the terminal, start Julia in the local Julia environment via `julia --project`.

Voila. We have an interactive REPL and could get going.

While this approach is perfectly fine, it doesn't use VS Code to its full potential: It simply gives you an editor and a Julia REPL. What it doesn't give you is any connection between the two. That is, VS Code essentially has no clue about Julia.

For this reason, and among other things, Julia plots won't show up in the VS Code plot pane, you won't be able to evaluate Julia code in-line in the editor, and you won't be able to use tools like the integrated profiler, debugger, and so on. For all of these things to work, you need to use the Julia VS Code extension.

## The "integrated Julia REPL"

Assuming that the extension is installed - in preparing for the workshop, you should have already installed the it - we do the following:

0. Kill the open Julia REPL (`exit()` or `CTRL + D`).

1. Start the "**integrated Julia REPL**" by pressing `ALT+J` followed by `ALT+O` (you need to let go of `ALT` temporarily). Alternatively, you can also press `CTRL+SHIFT+P` and then execute the command `Julia: Start REPL`. Either way, a Julia REPL should pop up in the bottom (might take some time the first time).

The very first time you do this, the VSCodeServer package might precompile. Wait until you see the `julia>` input prompt.

Note that while the REPL at the bottom visually looks identical to if you simply had executed `julia --project` in a terminal, this integrated Julia REPL is special in the sense that it is connected to the Julia extension and thus VS Code.

To get a glimpse of this, try the following:

2. Run the following Julia commands in the integrated Julia REPL:

    ```julia
    using Plots
    x = -π:0.1:π
    plot(x, sin.(x))
    ```
    
If everything is working as it should, a sine plot should show up in the VS Code plot pane.

A few more commands that are useful for controlling the integrated Julia REPL are:

* Open integrated Julia REPL: `Alt-J Alt-O`
* Kill integrated Julia REPL: `Alt-J Alt-K`
* Restart integrated Julia REPL: `Alt-J Alt-R`

While there is much [more to discover](https://www.julia-vscode.org/), we'll leave it at this for now.

## Using the extension on the cluster

A nice thing about this integrated setup is that it also works remotely on a cluster (e.g. displaying a plot without the requirement of X-forwarding).

1. Inside of VS Code, connect to the cluster using `CTRL + SHIFT + P` (or `CMD + SHIFT + P`) and then `Remote-SSH: Connect to Host...`.
2. On the cluster, open the extension tab in the sider bar on the left (`CTRL + SHIFT + X`).
3. Search for "Julia" and install the extension.

Shortly, the Julia extension should be installed.

### Pointing the extension to `julia_wrapper.sh`

So far, the extension doesn't know anything about `module`s on the cluster and thus can't automatically locate `julia`. We need to point it to the wrapper script, that is located at

```
/projects/julia/julia_wrapper.sh
```

To set the relevant setting:

1. Press `CTRL + ,` (comma) to open the Settings.
2. Select the tab (at the top) that says "Remote [delftblue]".
3. Search for "julia executable" and copy-paste the path above into the text field of the setting.
4. Close the settings tab.

**Note:** You should only have to do this **once**. VS Code should remember this setting.

### Testing the Julia VS Code integration

Let's run the same test as we did above.

1. Make sure to open the workshop directory on the cluster (`/scratch/$USER/JuliaDelft24`).
  - Tip: one simple way to do it is to open a terminal (`CTRL/CMD + ~` or `Terminal: Create New Terminal`), then do `cd /scratch/$USER/JuliaDelft24`, and finally `code -r .` (the dot is important).

2. Start the "integrated Julia REPL", press `ALT+J` followed by `ALT+O`. Alternatively, you can press `CTRL+SHIFT+P` and then execute the command `Julia: Start REPL`. Either way, a Julia REPL should pop up in the bottom (might take some time the first time).

The very first time you do this, the VSCodeServer package will precompile (for about a minute). Wait until you see the `julia>` input prompt.

3. Run the following Julia commands in the integrated Julia REPL:

    ```julia
    using Plots
    x = -π:0.1:π
    plot(x, sin.(x))
    ```
    
If everything is working, a sine plot should show up in the VS Code plot pane.

You're done 🎉. Feel free to play around further.
