---
name: security-unserialize
description: Prevent serialization vulnerabilities when using serialize, unserialize, or magic methods. Use when generating or editing PHP code with serialization; follows .agent/rules/security-unserialize.mdc.
---

# PHP Serialization Vulnerability Protection

## PHP Serialization Functions
PHP provides the builtin `serialize` and `unserialize` functions. These functions should be avoided if JSON encoding can be used instead.
The serialization functions should only be used if complex objects with many properties need to be encoded into a serialized representation.
If serialization is used, the `unserialize` calls that reconstruct this data into objects MUST be limited to only instantiate a hard coded
list of classes that are expected to be in the input passed to unserialize. Here is an example:

```
class DataItem {
    public $data;
    public function __construct($data) {$this->data = $data;}
}
 
// the only place we produce input I expect to be consumed by restoreAction()
function saveAction()
{
    $data = new DataItem("foo");
    $id = 1;
    saveToDatabase($id, serialize($data));
}
 
function restoreAction()
{
    $id = 1;
    // Only DataItem class objects should ever be present in this input to unserialize()
    $data = unserialize(restoreFromDatabase($id), ['allowed_classes' => ['DataItem']]);
}
```

If working with existing code that uses serialization, but does not need to support any classes and only contains data consisting of native PHP types (integers, strings, arrays, etc.)
modify the code to not allow unserialization of classes:
```
    $serialized_str = $this->request->getParam("serialized_input");
    $str = unserialize($serialized_str, ['allowed_classes' => false]); // no classes allowed
```

## PHP Magic Class Methods
PHP supports magic methods. Some of these methods can be abused as part of a serialization vulnerability.
Never generate the following methods for a class:
- __sleep()
- __wakeup()
- __destruct()
