# Lesson Submodules

Each lesson starter is its own repository, registered in this one as a git
submodule, the way `OODP_Lessons` does it.  This page covers making one,
publishing it, and getting all of them onto another computer.

The one rule that causes most of the trouble:  **this repository records an
exact commit of each lesson repo, and anyone cloning it can only get that commit
if it's already on GitHub.**  Push the lesson repo first, then this one.

## Cloning this repository onto another computer

From the folder that should hold it:

```
git clone --recurse-submodules https://github.com/cox-programming-classes/AlgorithmicThinking.git
```

If it was already cloned without that flag, the lesson folders will be empty.
Fill them from inside the repository:

```
git submodule update --init --recursive
```

Each lesson folder now holds the exact commit this repository recorded, in a
"detached HEAD" state.  Before working in one, put it back on its branch:

```
git -C Lesson01_RobotObjectModel switch main
```

## Pulling later

```
git pull
git submodule update --init --recursive
```

The second line brings each lesson folder to the commit the pull recorded, and
picks up any lesson added since the last pull.  To have every pull do it on its
own, set this once per computer:

```
git config --global submodule.recurse true
```

## Making a new starter

Register each new starter as a submodule as soon as it exists.  The steps:

1. Build the starter in its own folder at the top of this repository, beside
   `Course/` and `ReferenceCopy/`.  Name it `LessonNN_Name`.
2. Inside it:  `git init -b main`, add the files, and make the first commit.  A
   repository with no commits can't be a submodule.
3. From the top of this repository:

   ```
   git submodule add https://github.com/cox-programming-classes/LessonNN_Name.git LessonNN_Name
   ```

   This writes the URL into `.gitmodules` and nothing else.  **Don't run
   `git remote add` inside the lesson folder.**  A lesson repo with a remote
   hides GitHub Desktop's Publish button.
4. Check that it worked:

   ```
   cat .gitmodules
   git -C LessonNN_Name remote -v      # should print nothing
   git submodule status
   ```

5. Commit `.gitmodules` and the new folder in this repository.

## Publishing a starter with the GitHub CLI

This is the way Lesson 1 went up, and it's the quickest.  It needs `gh`
logged in on the computer (`gh auth status`; to log in, run
`gh auth login -h github.com -p https -w` in a normal terminal and enter the
one-time code it prints at https://github.com/login/device).

From the top of this repository:

```
gh repo create cox-programming-classes/LessonNN_Name --public --source=LessonNN_Name --remote=origin --push
```

That creates the repository on GitHub, sets the lesson's `origin` to it, and
pushes `main`, all in one step.  Lesson repos are public, like OODP's.

**An `origin` is fine here, and only here.**  The rule against `git remote add`
is about pointing at a GitHub repository that doesn't exist yet, which hides
GitHub Desktop's Publish button.  `gh repo create` makes the repository first,
so the `origin` it sets points at something real.

Then check, and push this repository:

```
git config -f .gitmodules submodule.LessonNN_Name.url    # should match the new repo
git submodule status                                      # no + or - in front
```

## Publishing a starter from GitHub Desktop

The other way, when `gh` isn't available.  Do this before pushing this
repository, every time a lesson repo has commits that this one points at.

1. **File > Add local repository**, and choose the lesson's folder.
2. **Publish repository.**  Choose the `cox-programming-classes` organization,
   and use the exact folder name as the repository name.
3. Back in this repository, check that `.gitmodules` matches where it went.  If
   it went somewhere else, fix it and commit:

   ```
   git submodule set-url LessonNN_Name https://github.com/<where-it-went>/LessonNN_Name.git
   ```

4. Then push this repository.

After a lesson repo changes later:  commit and push it first.  Then, in this
repository, commit the lesson folder (it shows as a changed submodule) and push.

## When it goes wrong

| What you see | What it means | Fix |
|---|---|---|
| A lesson folder is empty after cloning | the submodules were never fetched | `git submodule update --init --recursive` |
| `did not contain` or `not our ref` | this repository points at a lesson commit that was never pushed | push that lesson repo from the computer that has the commit, then try again |
| `Repository not found` | the URL in `.gitmodules` is wrong, the lesson isn't published yet, or you lack access | check `.gitmodules` against GitHub; fix with `git submodule set-url` |
| No Publish button in GitHub Desktop | the lesson repo has a remote already | `git -C LessonNN_Name remote remove origin`, then publish |
| Commits in a lesson folder seem to vanish | it was on a detached HEAD | `git -C LessonNN_Name switch main` before working; recover with `git reflog` |
