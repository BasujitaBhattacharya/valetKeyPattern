package com.valeykey.frontend;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ValeyKeyServlet")
public class ValeyKeyServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
      
    public ValeyKeyServlet() {
        super();
        
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, MalformedURLException {
		response.getWriter().append("Served at: ").append(request.getContextPath());
		
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, MalformedURLException {
		   
			String imageName = request.getParameter("imageName");
			String strSASToken = getToken(imageName);
			String strImageUrl = generateImageUrl(strSASToken,imageName);
		     
		    response.sendRedirect(strImageUrl);
	}
	
	protected String getToken(String imageName) throws IOException
	{
		imageName = imageName.concat(".jpg");
		String httpTriggerUrl = System.getenv("FunctionUrl");
		httpTriggerUrl = httpTriggerUrl.replace("{blobname}", imageName);	
		
		URL urlObj = new URL(httpTriggerUrl);
		
		URLConnection urlCon = urlObj.openConnection();
		 BufferedReader in = new BufferedReader(new InputStreamReader(
				 urlCon.getInputStream()));
		String strTokenReceived;
		String strToken = "";
		while ((strTokenReceived = in.readLine()) != null) 
		{
			strToken = strTokenReceived;
		}
		in.close();
		
		return strToken;
		
	}
	
	protected String generateImageUrl(String strSASToken, String strImageName) throws IOException
	{
		
		String fqdn=System.getenv("FQDN");
		String path=System.getenv("Location");
		String strImageUrl="https://"+fqdn+path+strImageName+".jpg?"+ strSASToken;
		
		return strImageUrl;
	
	}

}
