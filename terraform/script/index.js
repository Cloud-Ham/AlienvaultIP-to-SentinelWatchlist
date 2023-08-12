module.exports = async function (context, req) {
    try {
        // Get data from the request
        const plaintextData = req.body;

        // Regex pattern for matching IPv4 addr
        const ipv4Pattern = /\b(?:\d{1,3}\.){3}\d{1,3}\b/g;

        // Extract IPv4 addresses using the regex pattern
        const ipv4Addresses = plaintextData.match(ipv4Pattern) || [];

        // Return the array of extracted IPv4 addresses
        context.res = {
            status: 200,
            body: {
                ipv4Addresses: ipv4Addresses
            }
        };
    } catch (error) {
        context.res = {
            status: 500,
            body: {
                error: `Error: ${error.message}`
            }
        };
    }
};