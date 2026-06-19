package com.sap.cap.training.ui;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.GenericFilterBean;

/**
 * Redirects calls on relative paths coming from the Fiori apps in local
 * development to the correct service endpoints. In cloud deployments this is
 * not needed, as paths are managed differently by HTML5 apps repo & approuter.
 */
@Component
@Profile("!cloud")
public class RedirectFilter extends GenericFilterBean {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String[] uiServicePaths = {
            "/training_processor/webapp/processor",
            "/training_analytics/webapp/analytics",
            "/training_processor/dist/processor",
            "/training_analytics/dist/analytics"
        };

        String path = req.getRequestURI();
        for (String uiServicePath : uiServicePaths) {
            if (path.startsWith(uiServicePath)) {
                res.resetBuffer();
                res.setStatus(308);
                res.setHeader("Location", path.substring(uiServicePath.lastIndexOf('/')));
                res.flushBuffer();
                return;
            }
        }

        chain.doFilter(req, res);
    }

}
