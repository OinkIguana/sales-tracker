'use strict';
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const pg = require("pg");
const bcrypt = require("bcrypt");
const sql_template_strings_1 = require("sql-template-strings");
const config = {
    user: process.env.CONARTISTPGUSER || 'conartist_app',
    database: process.env.CONARTISTDB || 'conartist',
    password: process.env.CONARTISTPASSWORD || 'temporary-password',
    host: 'localhost',
    min: 1,
    max: process.env.CONARTISTDBPOOL || 10,
    idleTimeoutMillis: process.env.CONARTISTDBTIMEOUT || 1000 * 60,
};
const pool = new pg.Pool(config);
class DBError extends Error {
    constructor(message) {
        super(message);
        this.name = 'Database Error';
    }
}
function connect() {
    return pool.connect();
}
function query(query) {
    return pool.query(query);
}
function getCon(user_id, con_code, client) {
    return __awaiter(this, void 0, void 0, function* () {
        const { rows: raw_con } = yield client.query(sql_template_strings_1.default `SELECT * FROM Conventions WHERE con_code = ${con_code}`);
        if (!raw_con.length) {
            throw new DBError(`No con '${con_code}' exists`);
        }
        const [{ con_id }] = raw_con;
        const { rows: raw_user_con } = yield client.query(sql_template_strings_1.default `SELECT * FROM User_Conventions WHERE user_id = ${user_id} AND con_id = ${con_id}`);
        if (!raw_user_con.length) {
            throw new DBError(`Not registered for con ${raw_con[0].title}`);
        }
        return [raw_con[0], raw_user_con[0]];
    });
}
function getConInfo(user_id, con_code) {
    return __awaiter(this, void 0, void 0, function* () {
        const client = yield connect();
        try {
            const [raw_con, { user_con_id }] = yield getCon(user_id, con_code, client);
            const { rows: raw_types } = yield client.query(sql_template_strings_1.default `SELECT type_id, name, color FROM ProductTypes WHERE user_id = ${user_id}`);
            const { rows: raw_products } = yield client.query(sql_template_strings_1.default `SELECT product_id, type_id, name FROM Products WHERE user_id = ${user_id}`);
            const { rows: raw_inventory } = yield client.query(sql_template_strings_1.default `SELECT product_id, quantity FROM Inventory WHERE user_con_id = ${user_con_id}`);
            const { rows: raw_prices } = yield client.query(sql_template_strings_1.default `SELECT type_id, product_id, prices FROM Prices WHERE user_con_id = ${user_con_id}`);
            const { rows: raw_records } = yield client.query(sql_template_strings_1.default `SELECT products, price, sale_time FROM Records WHERE user_con_id = ${user_con_id}`);
            const types = raw_types
                .reduce((_, { type_id, name, color }) => (Object.assign({}, _, { [type_id]: { name, color, id: type_id } })), {});
            const products_by_id = raw_products
                .reduce((_, { product_id, type_id, name }) => (Object.assign({}, _, { [product_id]: {
                    name,
                    type: types[type_id].name,
                    id: product_id,
                } })), {});
            const products = raw_inventory
                .map(({ product_id, quantity }) => ({ product: products_by_id[product_id], quantity }))
                .reduce((_, { product: { type, name, id }, quantity }) => (Object.assign({}, _, { [type]: [
                    ...(_[type] || []),
                    { name, quantity, id },
                ] })), {});
            const prices = raw_prices
                .reduce((_, { type_id, product_id, prices }) => (Object.assign({}, _, { [`${types[type_id]}${product_id ? `::${products_by_id[product_id].name}` : ''}`]: prices })), {});
            const records = raw_records
                .map(({ products, price, sale_time }) => ({
                products: products.map((_) => products_by_id[_].name),
                price,
                time: sale_time,
                type: products_by_id[products[0]].type,
            }));
            const data = {
                products, prices, records, types,
            };
            const con = {
                start: new Date(raw_con.start_date),
                end: new Date(raw_con.end_date),
                title: raw_con.title,
                code: con_code,
                data,
            };
            return con;
        }
        catch (error) {
            throw error;
        }
        finally {
            client.release();
        }
    });
}
exports.getConInfo = getConInfo;
function writeRecords(user_id, con_code, records) {
    return __awaiter(this, void 0, void 0, function* () {
        const client = yield connect();
        try {
            const [, { user_con_id }] = yield getCon(user_id, con_code, client);
            for (const { price, products, time } of records) {
                yield client.query(sql_template_strings_1.default `INSERT INTO Records (user_con_id, price, products, sale_time) VALUES (${user_con_id}, ${price}, ${products}, ${time})`);
            }
        }
        catch (error) {
            throw error;
        }
        finally {
            client.release();
        }
    });
}
exports.writeRecords = writeRecords;
function getUserProducts(user_id) {
    return __awaiter(this, void 0, void 0, function* () {
        const client = yield connect();
        try {
            const { rows: raw_types } = yield client.query(sql_template_strings_1.default `SELECT type_id, name FROM ProductTypes WHERE user_id = ${user_id}`);
            const { rows: raw_products } = yield client.query(sql_template_strings_1.default `SELECT product_id, type_id, name FROM Products WHERE user_id = ${user_id}`);
            const { rows: raw_inventory } = yield client.query(sql_template_strings_1.default `SELECT quantity, product_id FROM Inventory WHERE user_id = ${user_id}`);
            const types = raw_types
                .reduce((_, { type_id, name }) => (Object.assign({}, _, { [type_id]: name })), {});
            const products_by_id = raw_products
                .reduce((_, { type_id, name, product_id }) => (Object.assign({}, _, { [product_id]: {
                    name,
                    type: types[type_id],
                    id: product_id,
                } })), {});
            const products = raw_inventory
                .map(({ product_id, quantity }) => ({ product: products_by_id[product_id], quantity }))
                .reduce((_, { product: { type, name, id }, quantity }) => (Object.assign({}, _, { [type]: [
                    ...(_[type] || []),
                    { name, quantity, id },
                ] })), {});
            return products;
        }
        catch (error) {
            throw error;
        }
        finally {
            client.release();
        }
    });
}
exports.getUserProducts = getUserProducts;
function getUserPrices(user_id) {
    return __awaiter(this, void 0, void 0, function* () {
        const client = yield connect();
        try {
            const { rows: raw_types } = yield client.query(sql_template_strings_1.default `SELECT type_id, name FROM ProductTypes WHERE user_id = ${user_id}`);
            const { rows: raw_products } = yield client.query(sql_template_strings_1.default `SELECT product_id, type_id, name FROM Products WHERE user_id = ${user_id}`);
            const { rows: raw_prices } = yield client.query(sql_template_strings_1.default `SELECT type_id, product_id, prices FROM Prices WHERE user_id = ${user_id}`);
            const types = raw_types
                .reduce((_, { type_id, name }) => (Object.assign({}, _, { [type_id]: name })), {});
            const products_by_id = raw_products
                .reduce((_, { product_id, type_id, name }) => (Object.assign({}, _, { [product_id]: {
                    name,
                    type: types[type_id],
                } })), {});
            const prices = raw_prices
                .reduce((_, { type_id, product_id, prices }) => (Object.assign({}, _, { [`${types[type_id]}${product_id ? `::${products_by_id[product_id].name}` : ''}`]: prices })), {});
            return prices;
        }
        catch (error) {
            throw error;
        }
        finally {
            client.release();
        }
    });
}
exports.getUserPrices = getUserPrices;
function writeProducts(user_id, products) {
    return __awaiter(this, void 0, void 0, function* () {
        const client = yield connect();
        try {
            for (const { id, name, quantity } of products) {
                if (name) {
                    yield client.query(sql_template_strings_1.default `UPDATE Products SET name = ${name} WHERE product_id = ${id}`);
                }
                if (quantity) {
                    yield client.query(sql_template_strings_1.default `UPDATE Inventory SET quantity = ${quantity} WHERE product_id = ${id} AND user_id = ${user_id}`);
                }
            }
        }
        catch (error) {
            throw error;
        }
        finally {
            client.release();
        }
    });
}
exports.writeProducts = writeProducts;
function writePrices(user_id, prices) {
    return __awaiter(this, void 0, void 0, function* () {
        const client = yield connect();
        try {
            for (const { type_id, product_id, price } of prices) {
                yield client.query(sql_template_strings_1.default `UPDATE Prices SET prices = ${price} WHERE type_id = ${type_id} AND product_id = ${product_id} AND user_id = ${user_id}`);
            }
        }
        catch (error) {
            throw error;
        }
        finally {
            client.release();
        }
    });
}
exports.writePrices = writePrices;
function userExists(usr) {
    return __awaiter(this, void 0, void 0, function* () {
        const { rows } = yield query(sql_template_strings_1.default `SELECT 1 FROM Users WHERE email = ${usr}`);
        return rows.length === 1;
    });
}
exports.userExists = userExists;
function logInUser(usr, psw) {
    return __awaiter(this, void 0, void 0, function* () {
        const client = yield connect();
        try {
            const { rows: raw_user } = yield client.query(sql_template_strings_1.default `SELECT user_id, password FROM Users WHERE email = ${usr}`);
            if (raw_user.length === 1) {
                const { user_id, password } = raw_user[0];
                if (yield bcrypt.compare(psw, password)) {
                    return { user_id };
                }
                else {
                    throw new DBError('Incorrect email or password');
                }
            }
            else {
                throw new DBError('Non-existent user');
            }
        }
        catch (error) {
            throw error;
        }
        finally {
            client.release();
        }
    });
}
exports.logInUser = logInUser;
function createUser(usr, psw) {
    return __awaiter(this, void 0, void 0, function* () {
        const client = yield connect();
        try {
            const hash = yield bcrypt.hash(psw, 10);
            const { rows } = yield query(sql_template_strings_1.default `SELECT 1 FROM Users WHERE email = ${usr}`);
            if (rows.length === 1) {
                throw new DBError(`An account is already registered to ${usr}`);
            }
            yield client.query(sql_template_strings_1.default `INSERT INTO Users (email, password) VALUES (${usr},${hash})`);
        }
        catch (error) {
            throw error;
        }
        finally {
            client.release();
        }
    });
}
exports.createUser = createUser;
