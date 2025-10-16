using System;
using System.Diagnostics;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

class Program
{
    static async Task Main()
    {
        // Build correct path to fusionexport-service.exe
        string exePath = Path.GetFullPath(
            Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "fusionexport-service.exe")
        );


        var startInfo = new ProcessStartInfo
        {
            FileName = exePath,
            WorkingDirectory = Path.GetDirectoryName(exePath),
            Arguments = "--port 8088",
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = false
        };

        var process = new Process { StartInfo = startInfo };

        process.OutputDataReceived += (s, e) => { if (e.Data != null) Console.WriteLine($"[OUT] {e.Data}"); };
        process.ErrorDataReceived += (s, e) => { if (e.Data != null) Console.WriteLine($"[ERR] {e.Data}"); };

        Console.WriteLine("🚀 Starting FusionExport service...");
        process.Start();
        process.BeginOutputReadLine();
        process.BeginErrorReadLine();

        // Give the service a few seconds to boot up
        await Task.Delay(4000);

        try
        {
            Console.WriteLine("📄 Preparing export request...");

            // Read your chart configuration JSON
            string chartConfigPath = Path.GetFullPath(
                Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "chartConfig.json")
            );            
            if (!File.Exists(chartConfigPath))
            {
                Console.WriteLine($"❌ Chart config not found at: {chartConfigPath}");
                return;
            }

            string json = await File.ReadAllTextAsync(chartConfigPath);

            using var httpClient = new HttpClient();

            var content = new StringContent(json, Encoding.UTF8, "application/json");

            Console.WriteLine("📤 Sending export request to FusionExport service...");

            // POST to the FusionExport service on port 8088
            var response = await httpClient.PostAsync("http://localhost:1337/api/v2.0/export", content);
            response.EnsureSuccessStatusCode();

            // Get the PDF bytes
            var bytes = await response.Content.ReadAsByteArrayAsync();

            string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
            string outputDir = Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "output");
            Directory.CreateDirectory(outputDir); // ensure 'output' folder exists
            string outputPath = Path.Combine(outputDir, $"export_{timestamp}.pdf");
            await File.WriteAllBytesAsync(outputPath, bytes);

            Console.WriteLine($"✅ Export complete! PDF saved at: {outputPath}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Export failed: {ex.Message}");
        }
        finally
        {
            Console.WriteLine("🛑 Stopping FusionExport service...");
            try
            {
                if (!process.HasExited)
                {
                    process.Kill();
                    process.WaitForExit();
                }
            }
            catch { /* ignore any cleanup exceptions */ }
        }
    }
}
