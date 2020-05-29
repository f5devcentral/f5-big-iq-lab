package mypackage;

import java.util.Iterator;
import com.google.gson.JsonArray;
import java.io.BufferedReader;
import java.io.FileWriter;
import com.google.gson.JsonElement;
import java.io.Reader;
import com.google.gson.JsonObject;
import com.google.gson.Gson;
import javax.servlet.ServletException;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletRequest;
import java.io.File;
import javax.servlet.http.HttpServlet;

public class Hello extends HttpServlet
{
    private static String tomcatBase;
    private static String rootPath;
    private static File acmeChallengePath;
    
    public void doGet(final HttpServletRequest request, final HttpServletResponse response) throws IOException, ServletException {
        response.setContentType("text/html");
        final PrintWriter out = response.getWriter();
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Loknath</title>");
        out.println("</head>");
        out.println("<body>");
        out.println("<h1>Testing ./well-known folder</h1>");
        if (Hello.acmeChallengePath.exists()) {
            final File[] listOfFiles = Hello.acmeChallengePath.listFiles();
            if (listOfFiles.length == 0) {
                out.println("<h2>Folder is empty</h2>");
            }
            for (int i = 0; i < listOfFiles.length; ++i) {
                if (listOfFiles[i].isFile()) {
                    out.println("<h2>File :" + listOfFiles[i].getName() + "</h2>");
                }
                else if (listOfFiles[i].isDirectory()) {
                    out.println("<h2>Directory :" + listOfFiles[i].getName() + "</h2>");
                }
            }
        }
        else {
            out.println("<h2>Folder not exist</h2>");
        }
        out.println("</body>");
        out.println("</html>");
    }
    
    public void doPost(final HttpServletRequest request, final HttpServletResponse response) throws IOException, ServletException {
        JsonObject requestData;
        try (final BufferedReader reader = request.getReader()) {
            final Gson gson = new Gson();
            requestData = (JsonObject)gson.fromJson((Reader)reader, (Class)JsonObject.class);
        }
        final JsonObject object = new JsonObject();
        boolean deleteChallenge = false;
        if (requestData.has("deleteChallenge")) {
            deleteChallenge = requestData.get("deleteChallenge").getAsBoolean();
        }
        final JsonArray challenges = requestData.getAsJsonArray("challenges");
        for (final JsonElement element : challenges) {
            final JsonObject challenge = element.getAsJsonObject();
            if (challenge.get("type").getAsString().contains("http")) {
                final String fileName = challenge.get("fileName").getAsString();
                object.addProperty("fileName", fileName);
                final String content = challenge.get("content").getAsString();
                object.addProperty("content", content);
                if (!Hello.acmeChallengePath.exists()) {
                    Hello.acmeChallengePath.mkdirs();
                }
                final File file = new File(Hello.acmeChallengePath, fileName);
                if (!deleteChallenge) {
                    if (file.createNewFile()) {
                        object.addProperty("File Creation", "New file created");
                    }
                    else {
                        object.addProperty("File Creation", "Existing file overwritten");
                    }
                    try (final FileWriter fw = new FileWriter(file.getAbsolutePath())) {
                        object.addProperty("FilePath ", file.getAbsolutePath());
                        fw.write(content);
                    }
                    catch (Exception ex) {
                        ex.printStackTrace();
                    }
                    break;
                }
                object.addProperty("Path", file.getAbsolutePath());
                if (!file.exists()) {
                    object.addProperty("File Deletion", "File Not Existing");
                    break;
                }
                if (file.delete()) {
                    object.addProperty("File Deletion", "Deleted");
                    break;
                }
                object.addProperty("File Deletion", "Failed");
                break;
            }
        }
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        final PrintWriter out = response.getWriter();
        out.println(object);
    }
    
    protected void doDelete(final HttpServletRequest request, final HttpServletResponse response) throws ServletException, IOException {
        JsonObject requestData;
        try (final BufferedReader reader = request.getReader()) {
            final Gson gson = new Gson();
            requestData = (JsonObject)gson.fromJson((Reader)reader, (Class)JsonObject.class);
        }
        final JsonObject object = new JsonObject();
        final JsonArray challenges = requestData.getAsJsonArray("challenges");
        for (final JsonElement element : challenges) {
            final JsonObject challenge = element.getAsJsonObject();
            if (challenge.get("type").getAsString().contains("http")) {
                final String fileName = challenge.get("fileName").getAsString();
                object.addProperty("fileName", fileName);
                if (!Hello.acmeChallengePath.exists()) {
                    Hello.acmeChallengePath.mkdirs();
                }
                final File file = new File(Hello.acmeChallengePath, fileName);
                object.addProperty("Path", file.getAbsolutePath());
                if (file.exists()) {
                    if (file.delete()) {
                        object.addProperty("File Deletion", "Deleted");
                    }
                    else {
                        object.addProperty("File Deletion", "Failed");
                    }
                }
                else {
                    object.addProperty("File Deletion", "File Not Existing");
                }
            }
        }
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        final PrintWriter out = response.getWriter();
        out.println(object);
    }
    
    static {
        Hello.tomcatBase = System.getProperty("catalina.base");
        Hello.rootPath = String.format("%s/webapps", Hello.tomcatBase);
        Hello.acmeChallengePath = new File(Hello.rootPath, ".well-known/acme-challenge");
    }
}