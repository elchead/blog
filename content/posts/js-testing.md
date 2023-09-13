---
title: Testable code has few mocks
taxonomies:
  tags:
    - "Programming"
resources:
  - name: "featured-image"
    src: "cover.jpg"
date: 2021-11-24
---

Testing can sometimes seem hard and tedious. We might be faced with complex setup logic and many mocks. But this is a smell of poor code design. When properly done, mocks are rarely needed. TDD helps to avoid tight coupling and it naturally tends towards functional code. In this post, I cover how the functional style leads to less error prone code and fewer code to be tested. Moreover, we will explore when it is proper to use mocks.

## Integration vs Operation

When solving a problem the process is always to break it up into smaller pieces. The problem solution is then just the composition of the smaller units. So we define functions for each subproblem and one integration function to solve the big problem. There should be a clear distinction between operation and integration (also see [Integration Operation Segregation Principle](https://clean-code-developer.com/grades/grade-1-red/#Integration_Operation_Segregation_Principle_IOSP)).
Each small unit should be independent, i.e. unaware of the other parts in the composition.

> Mocking is required when our decomposition strategy has failed, Eric Elliott

## Function composition

What was new to me is that composing functions do not need to be unit tested when they are truly independent. Because in such case we can use a generic composition utility.

Let's look at an example[^1]. The imperative and obvious solution to integrate is this:

[^1]: adopted from [Source](https://medium.com/javascript-scene/mocking-is-a-code-smell-944a70c90a6a)

```js
// Imperative composition
const composition = (x) => {
  const afterG = g(x);
  const afterF = f(afterG);
  return afterF;
};
```

In languages without first-class functions, there might be no way around this. But in most popular languages, such as JavaScript, you can do better. Function composition is declarative and avoids bugs such as passing or returning the wrong variable.

For the declarative composition, you can either define your own pipe (which could be error-prone) or use a library[^1]:

```js
// import pipe from 'lodash/fp/flow';
const pipe = (...fns) => x => fns.reduce((y, f) => f(y), x);
// Functions to compose
const g = n => n + 1;
const f = n => n * 2;
// Declarative composition
const doStuffBetter = pipe(g, f);
doStuffBetter(20), // 42
```

Note that `reduce` applies the accumulator on each value from left to right! There is also a reverse variant called `reduceRight`. This reduction would have given 41 as result.

Commonly, we have asynchronous calls in our code, but we can also compose promises! I think this is also where it really pays off - when you compose calls with side effects. Unit testing the integration function becomes tedious, because we need to stub all participants[^1]:

```js
// imperative
async function uploadFiles({ user, folder, files }) {
  const dbUser = await readUser({ user });
  const folderInfo = await getFolderInfo({ folder });
  if (await haveWriteAccess({ dbUser, folderInfo })) {
    return uploadToFolder({ dbUser, folderInfo, files });
  } else {
    throw new Error("No write access to that folder");
  }
}

// declarative
const asyncPipe =
  (...fns) =>
  (x) =>
    fns.reduce(async (y, f) => f(await y), x);
const uploadFiles = asyncPipe(
  readUser,
  getFolderInfo,
  haveWriteAccess,
  uploadToFolder
);

uploadFiles({ user, folder, files }).then(log);
```

As you see, the declarative `uploadFiles` function is just a function call - no logic to be tested! The correctness of the step order is not assured, but in most cases this is covered in integration tests. If it's complex logic, you might still write a unit test to test the correct step order of the composition.

I agree that the declarative implementation (`asyncPipe`) is more difficult to understand at first, but it is less error prone and more concise. `asyncPipe` is given an array of functions that it reduces. `y` is the previous result and we apply `f` on it's result. The second return value `x` is the initial value. This syntax confused me a bit, but the initial value obviously needs to be provided at some place. This is functional programming!

## The merits of Functional Programming

The paradigm leads to code that is easier to test, because it is a stateless input / output machine. Moreover, it leaves less room for bugs, because you only declare what you want to perform instead of how to do it (imperative). However, it's not possible to only rely on functional programming, because applications are stateful and have side effects (network requests, file operations, logging...).
A good strategy is to keep the business logic functional and move side effects to the outer boundary.

Let's consider the example of an online shop that decides to give some premium benefits to its loyal customers. Premium customers might benefit from special discounts and free shipping so we want to update their status in the database.
On the other hand, we might want to reach out to the inactive customers. The status of our customer is clearly business logic and it should not be mixed with database logic.
One approach would be to pass a database interface and mock it in the test.

```js
function updateCustomer(today,entry,db) {
	if(isLoyalCustomer(today,entry.date)){
		newEntry = {premium: true, ...entry}
		db.UpdateEntry(newEntry)
	}
	if(isInactiveCustomer(today,entry.date){
		newEntry = {inactive: true, ...entry}
		return db.UpdateEntry(newEntry)
	})
}
```

But there is a better approach that is declarative and easier to test:

```js
function updateCustomer(today,entry) {
	if(isLoyalCustomer(today,entry.date)){
		newEntry = {premium: true, ...entry}
		return new FileUpdate(newEntry)
	}
	if(isInactiveCustomer(today,entry.date){
		newEntry = {inactive: true, ...entry}
		return new FileUpdate(newEntry)
	})
	return new NoUpdate(entry)

}
```

It's clearer in the intent that the output is a return value instead of an input value with side effects. Also, there is no need to mock!
Of course there is still a missing piece for this variant - the mutable shell that applies the side effects.
In our case, there would be a `Persister`, which is a database wrapper that reads the update instructions. It's correctness would be covered in the integration test.

## When to use mocks

Be aware that mocks are sometimes the only way to test logic. But think what exactly needs to be tested. For testing the request handler of our express app, it's not necessary to create a mockserver. We only want to test the handler logic. Express logic to create the server with port allocation etc. does not need to be tested by us!

I find the distinction between handlers and servers especially clear in Golang:

```go
handler := newHelloHandler()

request := newRequest("Floyd")
response := httptest.NewRecorder()

handler.ServeHTTP(response, request)
assertStatus(t, response.Code, http.StatusOK)
assertResponseBody(t, response.Body.String(), "Hello Floyd")
```

The handler object includes all logic how to process requests, so we can use it to test the correct behavior. Note how only the response needs to be mocked (spied to be precise).

In Express.js, we do the same. We test the handler function and spy the response object.

```
const helloHandler  = (req, res) => res.send('Hello World!');

const expected = 'Hello World!';
const resSpy = {
	send: (actual) => assert.Equal(actual,expected)
}
hello({}, resSpy);
```

The request handler is at the outer layer of our application, i.e. it connects with external dependencies to cause side effects. In our case the external dependency is the response object which makes a network call. In that case it is justified and necessary to mock. The general guideline is to only mock external dependencies.

## Conclusion

By pushing the side effects to the outer layer of the application, we can mostly avoid mocks. Functional code is easy to test and allows to use function composition. This reduces the surface for bugs and saves us to write unit tests for integration functions.
Mocks have its place, but if it's not an external dependency it might be code smell.

If you want to learn more about testing, I can highly recommend [Unit Testing Principles, Practices, and Patterns](https://www.manning.com/books/unit-testing).
