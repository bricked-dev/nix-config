{
  /**
  Attributes for an enabled boolean option.

  # Type

  ```
  enabledOption :: a
  ```

  # Examples


  ```nix
  mkEnableOption "foo" // enabledOption
  ```
  */
  enabledOption = {
    default = true;
    example = false;
  };
}
