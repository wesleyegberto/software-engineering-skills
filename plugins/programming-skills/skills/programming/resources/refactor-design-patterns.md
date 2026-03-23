# Refactoring to implement a design pattern

Code that doesn’t follow established design patterns (like Singleton, Factory, or Observer) can lead to issues like tight coupling, lack of flexibility, or duplicated code.

You should help you use appropriate design patterns to make your code more flexible and maintainable. For example, it can recommend converting repetitive instantiations into a Factory pattern, or using the Observer pattern to decouple tightly connected classes.

## Example scenario

This JavaScript code creates three `Person` objects, each with `name` and `age` properties. It then uses the name of a person to retrieve and print their age.

```javascript id=person-module
class Person {
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }
}

var people = {};

function addPerson(name, age) {
  people[name] = new Person(name, age);
}

function getAge(name) {
  if (people[name]) {
    console.log(name + " is " + people[name].age + " years old.");
  } else {
    console.log("Person not found.");
  }
}

addPerson("Ana", 30);
addPerson("Mario", 25);
addPerson("Louise", 40);

getAge("Mario");
```

## Example prompt 1

```prompt
What design patterns could improve this code? Don't show me code examples.
```

## Example response 1

Suggests the following patterns:

* **Singleton pattern:** to ensure that there is only one instance of the `people` object.
* **Factory pattern:** to create a factory for creating `Person` objects.
* **Module pattern:** to encapsulate the `people` object and related functions within a module to avoid polluting the global namespace.

## Example prompt 2

You can now ask to implement the pattern that you feel is most appropriate.

```prompt
Refactor this code using the module pattern
```

## Example response 2

```javascript
const PersonModule = (function() {
  class Person {
    constructor(name, age) {
      this.name = name;
      this.age = age;
    }
  }

  const people = {};

  function addPerson(name, age) {
    people[name] = new Person(name, age);
  }

  function getAge(name) {
    if (people[name]) {
      console.log(name + " is " + people[name].age + " years old.");
    } else {
      console.log("Person not found.");
    }
  }

  return {
    addPerson,
    getAge
  };
})();

PersonModule.addPerson("Ana", 30);
PersonModule.addPerson("Mario", 25);
PersonModule.addPerson("Louise", 40);

PersonModule.getAge("Mario");
```

The module pattern improves code organization, enhances data privacy, and reduces the risk of naming conflicts, making the code more maintainable and scalable.
