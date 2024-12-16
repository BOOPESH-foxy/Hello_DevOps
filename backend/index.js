const express = require("express");
const app = express();
const PORT = 3000;

app.get("/status", (req, res) => {
    const uptime = process.uptime();
    res.json({ status: "OK", uptime: uptime.toFixed(2) });
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
