{
  /**
  Add context attributes to a module. This creates a new module with the specified context attributes that imports the given module.

  # Type

  ```
  setModuleContext :: a -> b -> c
  ```

  # Arguments

  context
  : Context attributes to add.

  module
  : Module to add the context attributes to.
  */
  setModuleContext = context: module:
    context // {imports = [module];};
}
