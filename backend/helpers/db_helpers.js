// File: taxi_driver_node-main/helpers/db_helpers.js

const mysql = require('mysql2');
const config = require('config');
const dbConfig = config.get('dbConfig');
const moment = require('moment-timezone');

// إنشاء تجمع الاتصالات (Connection Pool)
const pool = mysql.createPool({
    ...dbConfig,
    waitForConnections: true,
    connectionLimit: 100,
    queueLimit: 0
});

module.exports = {
    query: (sqlQuery, args, callback) => {
        pool.query(sqlQuery, args, (error, result) => {
            if (error) {
                Dlog('---------------------------- DB Error (' + serverYYYYMMDDHHmmss() + ') -------------------------');
                Dlog(error.code);

                if ([
                    "PROTOCOL_CONNECTION_LOST",
                    "PROTOCOL_ENQUEUE_AFTER_QUIT",
                    "PROTOCOL_ENQUEUE_AFTER_FATAL_ERROR",
                    "PROTOCOL_ENQUEUE_HANDSHAKE_TWICE",
                    "ECONNREFUSED",
                    "PROTOCOL_PACKETS_OUT_OF_ORDER"
                ].includes(error.code)) {
                    Dlog(`/!\\ ${error.code} Cannot establish a connection with the database. /!\\`);
                }

                return callback(error, null);
            }

            return callback(null, result);
        });
    }
};

// التعامل مع كراش التطبيق
process.on('uncaughtException', (err) => {
    Dlog('------------------------ App is Crash DB helper (' + serverYYYYMMDDHHmmss() + ') -------------------------');
    Dlog(err.code || err.message || 'Unknown Error');
    console.error(err);
});

// دالة لعرض التاريخ بالتنسيق المحدد
function serverYYYYMMDDHHmmss() {
    return moment().tz("Asia/Kolkata").format('YYYY-MM-DD HH:mm:ss');
}

// دالة تسجيل في الكونسول
function Dlog(log) {
    console.log(log);
}
