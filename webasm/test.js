const fs = require("fs");

const module_path = process.argv[2];

const add_two_source = fs.readFileSync(`${module_path}/add_two.wasm`);
const math_source = fs.readFileSync(`${module_path}/math.wasm`);
const add_two_typedArray = new Uint8Array(add_two_source);
const math_typedArray = new Uint8Array(math_source);

WebAssembly.instantiate(add_two_typedArray, {
  env: {},
}).then((result) => {
  console.log(result?.instance?.exports);
  const add = result.instance.exports.add;
  console.log(add);
  console.log(`The result is ${add(1, 2)}`);

  const add_three = result.instance.exports.add_three;
  console.log(add_three);
  console.log(`The result is ${add_three(1, 2, 3)}`);
});

WebAssembly.instantiate(math_typedArray, {
  env: {
    print: (result) => {
      console.log(`The result is ${result}`);
    },
  },
}).then((result) => {
  console.log(result?.instance?.exports);
  const add = result.instance.exports.add;
  console.log(add);

  add(1, 2);
});
