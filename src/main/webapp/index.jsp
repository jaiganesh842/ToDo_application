<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="./Css/index.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cedarville+Cursive&family=Dancing+Script&display=swap" rel="stylesheet">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Tilt+Prism&display=swap" rel="stylesheet">
  <meta charset="ISO-8859-1">
  <title>Main</title>
</head>
<body>
<%
  List<String> items = (List<String>) session.getAttribute("Mytodoapp");
  if (items == null) {
    items = new ArrayList<String>();
    session.setAttribute("Mytodoapp", items);
  }

  String theItem = request.getParameter("theItem");
  if (theItem != null && !theItem.isEmpty() && request.getParameter("Add") != null) {
    items.add(theItem);
  }

  String removeItem = request.getParameter("remove");
  if (removeItem != null && !removeItem.isEmpty()) {
    items.remove(removeItem);
  }
%>
<h2 class="heading">To Do Application</h2>
<div class="container">
  <form class="form1" action="index.jsp" method="post">
    <div class="input-container">
      <input class="input1" type="text" name="theItem">
      <input class="Add" type="submit" value="Add" name="Add" />
    </div>
  </form>

  <p>The Items Are :</p>
  <ol>
    <% for (String temp : items) { %>
    <li>
      <div class="item-container">
         <div class="item-content"><%= temp.substring(0, 1).toUpperCase() + temp.substring(1) %></div>
        <form class="form2" action="index.jsp" method="post">
          <input type="hidden" name="remove" value="<%=temp%>" />
          <input class="remove" type="submit" value="Remove" />
        </form>
      </div>	
    </li>
    <% } %>
  </ol>
</div>
</body>
</html>
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;
import org.springframework.http.*;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;
import sgcib.tsf.dragonBook.model.api.GalaxyInstrumentResponse;
import sgcib.tsf.dragonBook.model.api.TranscodeRequest;
import sgcib.tsf.dragonBook.services.GalaxyConnectorServiceImpl;

import java.util.List;

import static org.junit.Assert.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@RunWith(MockitoJUnitRunner.class)
public class GalaxyConnectorServiceImplTest {

    @Mock
    private RestTemplate restTemplateMock;

    @InjectMocks
    private GalaxyConnectorServiceImpl galaxyConnectorServiceImpl;

    @Before
    public void setup() {
        // Setting the galaxyUrl value
        galaxyConnectorServiceImpl.galaxyUrl = "https://galaxy-testing/api/v1/instruments";
    }

    @Test
    public void testGetEliotCode_Success() {
        List<String> bbgCodes = List.of("BBG123");
        TranscodeRequest transcodeRequest = new TranscodeRequest();
        transcodeRequest.setCodeId("FIN_ID_TICKER");
        transcodeRequest.setCodeValues(bbgCodes);
        transcodeRequest.setStaticAttributes(List.of("FIN_ID_TICKER", "FIN_ID_ELIOT"));
        
        GalaxyInstrumentResponse galaxyInstrumentResponse = new GalaxyInstrumentResponse();
        ResponseEntity<GalaxyInstrumentResponse> responseEntity = ResponseEntity.ok(galaxyInstrumentResponse);

        when(restTemplateMock.exchange(
            eq("https://galaxy-testing/api/v1/instruments"),
            eq(HttpMethod.POST),
            any(HttpEntity.class),
            eq(GalaxyInstrumentResponse.class)
        )).thenReturn(responseEntity);

        List<GalaxyInstrumentResponse> result = galaxyConnectorServiceImpl.getEliotCode(bbgCodes);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(galaxyInstrumentResponse, result.get(0));
    }

    @Test
    public void testGetEliotCode_HttpServerErrorException() {
        List<String> bbgCodes = List.of("BBG123");
        HttpServerErrorException serverErrorException = new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR);

        when(restTemplateMock.exchange(
            eq("https://galaxy-testing/api/v1/instruments"),
            eq(HttpMethod.POST),
            any(HttpEntity.class),
            eq(GalaxyInstrumentResponse.class)
        )).thenThrow(serverErrorException);

        try {
            galaxyConnectorServiceImpl.getEliotCode(bbgCodes);
            fail("Expected HttpServerErrorException to be thrown");
        } catch (HttpServerErrorException e) {
            assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, e.getStatusCode());
        }
    }

    @Test
    public void testGetBbgEliotCode_Success() {
        List<String> bdrIds = List.of("BDR123");
        TranscodeRequest transcodeRequest = new TranscodeRequest();
        transcodeRequest.setCodeId("FIN_ID_BOR");
        transcodeRequest.setCodeValues(bdrIds);
        transcodeRequest.setStaticAttributes(List.of("FIN_ID_BOR", "FIN_ID_TICKER", "FIN_ID_ELIOT"));
        
        GalaxyInstrumentResponse galaxyInstrumentResponse = new GalaxyInstrumentResponse();
        ResponseEntity<GalaxyInstrumentResponse> responseEntity = ResponseEntity.ok(galaxyInstrumentResponse);

        when(restTemplateMock.exchange(
            eq("https://galaxy-testing/api/v1/instruments"),
            eq(HttpMethod.POST),
            any(HttpEntity.class),
            eq(GalaxyInstrumentResponse.class)
        )).thenReturn(responseEntity);

        List<GalaxyInstrumentResponse> result = galaxyConnectorServiceImpl.getBbgEliotCode(bdrIds);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(galaxyInstrumentResponse, result.get(0));
    }

    @Test
    public void testGetBbgEliotCode_HttpServerErrorException() {
        List<String> bdrIds = List.of("BDR123");
        HttpServerErrorException serverErrorException = new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR);

        when(restTemplateMock.exchange(
            eq("https://galaxy-testing/api/v1/instruments"),
            eq(HttpMethod.POST),
            any(HttpEntity.class),
            eq(GalaxyInstrumentResponse.class)
        )).thenThrow(serverErrorException);

        try {
            galaxyConnectorServiceImpl.getBbgEliotCode(bdrIds);
            fail("Expected HttpServerErrorException to be thrown");
        } catch (HttpServerErrorException e) {
            assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, e.getStatusCode());
        }
    }
}
------------------------------------------------------------------------------------
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.*;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;
import sgcib.tsf.dragonBook.DragonBookApplication;
import sgcib.tsf.dragonBook.model.api.GalaxyInstrumentResponse;
import sgcib.tsf.dragonBook.model.api.TranscodeRequest;
import sgcib.tsf.dragonBook.services.GalaxyConnectorServiceImpl;

import java.util.List;

import static org.junit.Assert.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@SpringBootTest(classes = DragonBookApplication.class)
@ContextConfiguration
@ActiveProfiles("test")
@RunWith(SpringRunner.class)
@ExtendWith(SpringExtension.class)
public class GalaxyConnectorServiceImplTest {

    @Mock
    private RestTemplate restTemplateMock;

    @InjectMocks
    private GalaxyConnectorServiceImpl galaxyConnectorServiceImpl;

    @Autowired
    private TranscodeRequest transcodeRequest;

    @Before
    public void setup() {
        // Setting the galaxyUrl value
        galaxyConnectorServiceImpl.galaxyUrl = "https://galaxy-testing/api/v1/instruments";
    }

    @Test
    public void testGetEliotCode_Success() {
        List<String> bbgCodes = List.of("BBG123");
        transcodeRequest.setCodeId("FIN_ID_TICKER");
        transcodeRequest.setCodeValues(bbgCodes);
        transcodeRequest.setStaticAttributes(List.of("FIN_ID_TICKER", "FIN_ID_ELIOT"));

        GalaxyInstrumentResponse galaxyInstrumentResponse = new GalaxyInstrumentResponse();
        ResponseEntity<GalaxyInstrumentResponse> responseEntity = ResponseEntity.ok(galaxyInstrumentResponse);

        when(restTemplateMock.exchange(
            eq("https://galaxy-testing/api/v1/instruments"),
            eq(HttpMethod.POST),
            any(HttpEntity.class),
            eq(GalaxyInstrumentResponse.class)
        )).thenReturn(responseEntity);

        List<GalaxyInstrumentResponse> result = galaxyConnectorServiceImpl.getEliotCode(bbgCodes);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(galaxyInstrumentResponse, result.get(0));
    }

    @Test
    public void testGetEliotCode_HttpServerErrorException() {
        List<String> bbgCodes = List.of("BBG123");
        transcodeRequest.setCodeId("FIN_ID_TICKER");
        transcodeRequest.setCodeValues(bbgCodes);
        transcodeRequest.setStaticAttributes(List.of("FIN_ID_TICKER", "FIN_ID_ELIOT"));

        HttpServerErrorException serverErrorException = new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR);

        when(restTemplateMock.exchange(
            eq("https://galaxy-testing/api/v1/instruments"),
            eq(HttpMethod.POST),
            any(HttpEntity.class),
            eq(GalaxyInstrumentResponse.class)
        )).thenThrow(serverErrorException);

        HttpServerErrorException thrownException = assertThrows(
            HttpServerErrorException.class,
            () -> galaxyConnectorServiceImpl.getEliotCode(bbgCodes)
        );

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, thrownException.getStatusCode());
    }

    @Test
    public void testGetBbgEliotCode_Success() {
        List<String> bdrIds = List.of("BDR123");
        transcodeRequest.setCodeId("FIN_ID_BOR");
        transcodeRequest.setCodeValues(bdrIds);
        transcodeRequest.setStaticAttributes(List.of("FIN_ID_BOR", "FIN_ID_TICKER", "FIN_ID_ELIOT"));

        GalaxyInstrumentResponse galaxyInstrumentResponse = new GalaxyInstrumentResponse();
        ResponseEntity<GalaxyInstrumentResponse> responseEntity = ResponseEntity.ok(galaxyInstrumentResponse);

        when(restTemplateMock.exchange(
            eq("https://galaxy-testing/api/v1/instruments"),
            eq(HttpMethod.POST),
            any(HttpEntity.class),
            eq(GalaxyInstrumentResponse.class)
        )).thenReturn(responseEntity);

        List<GalaxyInstrumentResponse> result = galaxyConnectorServiceImpl.getBbgEliotCode(bdrIds);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(galaxyInstrumentResponse, result.get(0));
    }

    @Test
    public void testGetBbgEliotCode_HttpServerErrorException() {
        List<String> bdrIds = List.of("BDR123");
        transcodeRequest.setCodeId("FIN_ID_BOR");
        transcodeRequest.setCodeValues(bdrIds);
        transcodeRequest.setStaticAttributes(List.of("FIN_ID_BOR", "FIN_ID_TICKER", "FIN_ID_ELIOT"));

        HttpServerErrorException serverErrorException = new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR);

        when(restTemplateMock.exchange(
            eq("https://galaxy-testing/api/v1/instruments"),
            eq(HttpMethod.POST),
            any(HttpEntity.class),
            eq(GalaxyInstrumentResponse.class)
        )).thenThrow(serverErrorException);

        HttpServerErrorException thrownException = assertThrows(
            HttpServerErrorException.class,
            () -> galaxyConnectorServiceImpl.getBbgEliotCode(bdrIds)
        );

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, thrownException.getStatusCode());
    }
}

