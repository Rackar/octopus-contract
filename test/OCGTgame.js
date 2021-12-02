// We import Chai to use its asserting functions here.
const { expect } = require("chai");

// `describe` is a Mocha function that allows you to organize your tests. It's
// not actually needed, but having your tests organized makes debugging them
// easier. All Mocha functions are available in the global scope.

// `describe` receives the name of a section of your test suite, and a callback.
// The callback must define the tests of that section. This callback can't be
// an async function.
describe("Game contract", function () {
    // Mocha has four functions that let you hook into the the test runner's
    // lifecyle. These are: `before`, `beforeEach`, `after`, `afterEach`.

    // They're very useful to setup the environment for tests, and to clean it
    // up after they run.

    // A common pattern is to declare some variables, and assign them in the
    // `before` and `beforeEach` callbacks.

    let Token;
    let hardhatToken;
    let owner;
    let addr1;
    let addr2;
    let addrs;

    // `beforeEach` will run before each test, re-deploying the contract every
    // time. It receives a callback, which can be async.
    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        Token = await ethers.getContractFactory("OCGTgame");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        // To deploy our contract, we just have to call Token.deploy() and await
        // for it to be deployed(), which happens onces its transaction has been
        // mined.
        hardhatToken = await Token.deploy();
        // await hardhatToken.deployed();

        // We can interact with the contract by calling `hardhatToken.method()`
        await hardhatToken.deployed();
    });

    // You can nest describe calls to create subsections.
    describe("Game function", function () {
        // `it` is another Mocha function. This is the one you use to define your
        // tests. It receives the test name, and a callback function.

        // If the callback function is async, Mocha will `await` it.
        it("Should check Lucky number ok", async function () {
            // Expect receives a value, and wraps it in an assertion objet. These
            // objects have a lot of utility methods to assert values.

            // This test expects the owner variable stored in the contract to be equal
            // to our Signer's owner.
            console.log(bytes('1'), bytes32(1));
            expect(await hardhatToken.checkLucky(1, '1')).to.equal(true);
            // expect(await hardhatToken.checkLucky(1, '2')).to.equal(false);
            // expect(await hardhatToken.checkLucky(0, '0')).to.equal(true);
            // expect(await hardhatToken.checkLucky(0, '00')).to.equal(false);
        });

        it("Should check color ok", async function () {
            // Expect receives a value, and wraps it in an assertion objet. These
            // objects have a lot of utility methods to assert values.

            // This test expects the owner variable stored in the contract to be equal
            // to our Signer's owner.
            expect(await hardhatToken.checkColor(0, 'red')).to.equal(true);
            expect(await hardhatToken.checkColor(1, 'green')).to.equal(true);
            expect(await hardhatToken.checkColor(2, 'blue')).to.equal(true);
            expect(await hardhatToken.checkColor(1, 'red')).to.equal(false);
        });


    });


});
