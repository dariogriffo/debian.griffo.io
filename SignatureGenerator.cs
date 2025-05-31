using System;
using System.Security.Cryptography;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text.RegularExpressions;

public class SignatureGenerator
{
    private const string SIGNATURE_PARAM = "signature";

    /// <summary>
    /// Generates a SHA-512 signature for the given dictionary payload using the provided secret key.
    /// </summary>
    /// <param name="payload">The dictionary containing key-value pairs to sign</param>
    /// <param name="secretKey">The secret key used for signing</param>
    /// <returns>The generated signature as a hexadecimal string</returns>
    public static string GenerateSignature(Dictionary<string, string> payload, string secretKey)
    {
        if (payload == null || !payload.Any())
            throw new ArgumentNullException(nameof(payload));
        
        if (string.IsNullOrEmpty(secretKey))
            throw new ArgumentNullException(nameof(secretKey));

        // Create a copy of the payload without the signature parameter
        var payloadWithoutSignature = payload
            .Where(kvp => !string.Equals(kvp.Key, SIGNATURE_PARAM, StringComparison.OrdinalIgnoreCase))
            .ToDictionary(kvp => kvp.Key, kvp => kvp.Value);

        // 1. URL encode all keys and values
        var encodedParams = payloadWithoutSignature
            .Select(kvp => new KeyValuePair<string, string>(
                HttpUtility.UrlEncode(kvp.Key),
                HttpUtility.UrlEncode(kvp.Value)
            ))
            .ToList();

        // 2. Sort parameters alphabetically by key
        var sortedParams = encodedParams
            .OrderBy(kvp => kvp.Key)
            .ToList();

        // 3. Create query string and normalize line endings
        var queryString = string.Join("&", 
            sortedParams.Select(kvp => $"{kvp.Key}={kvp.Value}"));

        // Normalize line endings to \n
        queryString = Regex.Replace(queryString, @"\r\n?|\n", "\n");

        // 4. Append signature key to the normalized string
        var stringToHash = queryString + secretKey;

        // 5. Generate SHA-512 signature
        using (var sha512 = SHA512.Create())
        {
            byte[] hashBytes = sha512.ComputeHash(Encoding.UTF8.GetBytes(stringToHash));
            return BitConverter.ToString(hashBytes).Replace("-", "").ToLower();
        }
    }
} 