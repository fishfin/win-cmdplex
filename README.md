# [[fishfin] win-cmdplex](https://github.com/fishfin/win-cmdplex)

> ```#windows-bat``` ```#parallelism```

A Windows .bat file that runs commands from an input file parallelly. Additionally, it can be instructed to run specific number of iterations.

### Usage

```bash
$ cmdplex d:\myproj\commands.txt 10
```

where ```commands.txt``` might contain any Windows commands. Example:

```bash
php d:\scripts\update.php --dtrange=20170101-20171231 --limit=5000
php d:\scripts\update.php --dtrange=20180101-20181231 --limit=5000
php d:\scripts\update.php --dtrange=20190101-20191231 --limit=5000
php d:\scripts\update.php --dtrange=20200101-20201231 --limit=5000
```

In this case, Win-CmdPlex will run the 4 commands parallelly, 10 times.

### Special Note

Please note that an iteration is triggered only if all commands within the iteration have completed. In other words, if a particular command completes earlier than the rest within an iteration, that command will wait till the last command in that iteration completes.