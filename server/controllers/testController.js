const db = require("../config/db");

exports.testConnection = async (req, res) => {
    try {
        const [result] = await db.execute(
            "SELECT ? AS message",
            ["SQL injection protection enabled"]
        );

        return res.status(200).json({
            success: true,
            message: "Backend and database are running successfully.",
            security: result[0].message
        });

    } catch (error) {
        console.error("Database error:", error.message);

        return res.status(500).json({
            success: false,
            message: "Database operation failed."
        });
    }
};