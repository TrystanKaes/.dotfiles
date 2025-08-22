# The Local Stuff

## Anything put here will:

1. Be excluded from git pushes.
2. Be sourced on terminal-load if it is prepended with a `'.'`.

## Adding new things

1. Remove "`local/`" from `.dotfiles/.gitignore`.
2. Add the file/changes you want:

   ```sh
   git add local/.<my-special-file>
   ```

3. Add back `local/` to `.dotfiles/.gitignore`.
4. Commit and push the changes

   ```sh
   git commit -m "Adding <my-special-file>"
   ```

5. Remove the file from git's tracking:
   ```sh
   git update-index --assume-unchanged local/.<my-special-file>
   ```

NOTE: If you want to later update them run:

    ```sh
    git update-index --no-assume-unchanged local/.<my-special-file>
    ```
