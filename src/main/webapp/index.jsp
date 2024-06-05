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
import com.google.common.collect.Lists;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.*;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;
import sgcib.tsf.dragonBook.DragonBookApplication;
import sgcib.tsf.dragonBook.model.api.GalaxyInstrumentResponse;
import sgcib.tsf.dragonBook.model.api.TranscodeRequest;
import sgcib.tsf.dragonBook.services.GalaxyConnectorServiceImpl;

import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

@SpringBootTest(classes = DragonBookApplication.class)
@ContextConfiguration
@ActiveProfiles("test")
@RunWith(SpringRunner.class)
@ExtendWith(SpringExtension.class)
public class GalaxyConnectorServiceImplTest {

    @Mock
    private RestTemplate restTemplateMock;

    private GalaxyConnectorServiceImpl galaxyConnectorServiceImpl;

    @Before
    public void setup() {
        restTemplateMock = mock(RestTemplate.class);
        galaxyConnectorServiceImpl = new GalaxyConnectorServiceImpl(restTemplateMock);
    }

    @Test
    public void testGetEliotCode() {
        String galaxyUrl = "https://galaxy-testing/api/v1/instruments";
        galaxyConnectorServiceImpl.galaxyUrl = galaxyUrl;

        List<String> bbgCodes = List.of("BBG123");
        TranscodeRequest transcodeRequest = new TranscodeRequest();
        transcodeRequest.setCodeId("FIN_ID_TICKER");
        transcodeRequest.setCodeValues(bbgCodes);
        transcodeRequest.setStaticAttributes(List.of("FIN_ID_TICKER", "FIN_ID_ELIOT"));

        GalaxyInstrumentResponse galaxyInstrumentResponse = new GalaxyInstrumentResponse();
        ResponseEntity<GalaxyInstrumentResponse> responseEntity = ResponseEntity.ok(galaxyInstrumentResponse);

        HttpEntity<TranscodeRequest> requestEntity = new HttpEntity<>(transcodeRequest);

        when(restTemplateMock.exchange(
            eq(galaxyUrl),
            eq(HttpMethod.POST),
            eq(requestEntity),
            eq(GalaxyInstrumentResponse.class)
        )).thenReturn(responseEntity);

        List<GalaxyInstrumentResponse> result = galaxyConnectorServiceImpl.getEliotCode(bbgCodes);
        Assert.assertNotNull(result);
        Assert.assertEquals(1, result.size());
        Assert.assertEquals(galaxyInstrumentResponse, result.get(0));
    }

    @Test(expected = HttpServerErrorException.class)
    public void testGetEliotCodeThrowsException() {
        String galaxyUrl = "https://galaxy-testing/api/v1/instruments";
        galaxyConnectorServiceImpl.galaxyUrl = galaxyUrl;

        List<String> bbgCodes = List.of("BBG123");
        TranscodeRequest transcodeRequest = new TranscodeRequest();
        transcodeRequest.setCodeId("FIN_ID_TICKER");
        transcodeRequest.setCodeValues(bbgCodes);
        transcodeRequest.setStaticAttributes(List.of("FIN_ID_TICKER", "FIN_ID_ELIOT"));

        HttpEntity<TranscodeRequest> requestEntity = new HttpEntity<>(transcodeRequest);

        when(restTemplateMock.exchange(
            eq(galaxyUrl),
            eq(HttpMethod.POST),
            eq(requestEntity),
            eq(GalaxyInstrumentResponse.class)
        )).thenThrow(new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR));

        galaxyConnectorServiceImpl.getEliotCode(bbgCodes);
    }

    @Test
    public void testGetBbgEliotCode() {
        String galaxyUrl = "https://galaxy-testing/api/v1/instruments";
        galaxyConnectorServiceImpl.galaxyUrl = galaxyUrl;

        List<String> bdrIds = List.of("BDR123");
        TranscodeRequest transcodeRequest = new TranscodeRequest();
        transcodeRequest.setCodeId("FIN_ID_BOR");
        transcodeRequest.setCodeValues(bdrIds);
        transcodeRequest.setStaticAttributes(List.of("FIN_ID_BOR", "FIN_ID_TICKER", "FIN_ID_ELIOT"));

        GalaxyInstrumentResponse galaxyInstrumentResponse = new GalaxyInstrumentResponse();
        ResponseEntity<GalaxyInstrumentResponse> responseEntity = ResponseEntity.ok(galaxyInstrumentResponse);

        HttpEntity<TranscodeRequest> requestEntity = new HttpEntity<>(transcodeRequest);

        when(restTemplateMock.exchange(
            eq(galaxyUrl),
            eq(HttpMethod.POST),
            eq(requestEntity),
            eq(GalaxyInstrumentResponse.class)
        )).thenReturn(responseEntity);

        List<GalaxyInstrumentResponse> result = galaxyConnectorServiceImpl.getBbgEliotCode(bdrIds);
        Assert.assertNotNull(result);
        Assert.assertEquals(1, result.size());
        Assert.assertEquals(galaxyInstrumentResponse, result.get(0));
    }

    @Test(expected = HttpServerErrorException.class)
    public void testGetBbgEliotCodeThrowsException() {
        String galaxyUrl = "https://galaxy-testing/api/v1/instruments";
        galaxyConnectorServiceImpl.galaxyUrl = galaxyUrl;

        List<String> bdrIds = List.of("BDR123");
        TranscodeRequest transcodeRequest = new TranscodeRequest();
        transcodeRequest.setCodeId("FIN_ID_BOR");
        transcodeRequest.setCodeValues(bdrIds);
        transcodeRequest.setStaticAttributes(List.of("FIN_ID_BOR", "FIN_ID_TICKER", "FIN_ID_ELIOT"));

        HttpEntity<TranscodeRequest> requestEntity = new HttpEntity<>(transcodeRequest);

        when(restTemplateMock.exchange(
            eq(galaxyUrl),
            eq(HttpMethod.POST),
            eq(requestEntity),
            eq(GalaxyInstrumentResponse.class)
        )).thenThrow(new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR));

        galaxyConnectorServiceImpl.getBbgEliotCode(bdrIds);
    }

    @Test
    public void testGetGalaxyInstrumentResponse() {
        String galaxyUrl = "https://galaxy-testing/api/v1/instruments";
        galaxyConnectorServiceImpl.galaxyUrl = galaxyUrl;

        List<String> bbgCodes = List.of("BBG123");
        TranscodeRequest transcodeRequest = new TranscodeRequest();
        transcodeRequest.setCodeId("FIN_ID_TICKER");
        transcodeRequest.setCodeValues(bbgCodes);
        transcodeRequest.setStaticAttributes(List.of("FIN_ID_TICKER", "FIN_ID_ELIOT"));

        GalaxyInstrumentResponse galaxyInstrumentResponse = new GalaxyInstrumentResponse();
        ResponseEntity<GalaxyInstrumentResponse> responseEntity = ResponseEntity.ok(galaxyInstrumentResponse);

        HttpEntity<TranscodeRequest> requestEntity = new HttpEntity<>(transcodeRequest);

        when(restTemplateMock.exchange(
            eq(galaxyUrl),
            eq(HttpMethod.POST),
            eq(requestEntity),
            eq(GalaxyInstrumentResponse.class)
        )).thenReturn(responseEntity);

        ResponseEntity<GalaxyInstrumentResponse> response = galaxyConnectorServiceImpl.getGalaxyInstrumentResponse(bbgCodes, transcodeRequest, List.of("FIN_ID_TICKER", "FIN_ID_ELIOT"));
        Assert.assertNotNull(response);
        Assert.assertEquals(responseEntity, response);
    }

    @Test(expected = HttpServerErrorException.class)
    public void testGetGalaxyInstrumentResponseThrowsException() {
        String galaxyUrl = "https://galaxy-testing/api/v1/instruments";
        galaxyConnectorServiceImpl.galaxyUrl = galaxyUrl;

        List<String> bbgCodes = List.of("BBG123");
        TranscodeRequest transcodeRequest = new TranscodeRequest();
        transcodeRequest.setCodeId("FIN_ID_TICKER");
        transcodeRequest.setCodeValues(bbgCodes);
        transcodeRequest.setStaticAttributes(List.of("FIN_ID_TICKER", "FIN_ID_ELIOT"));

        HttpEntity<TranscodeRequest> requestEntity = new HttpEntity<>(transcodeRequest);

        when(restTemplateMock.exchange(
            eq(galaxyUrl),
            eq(HttpMethod.POST),
            eq(requestEntity),
            eq(GalaxyInstrumentResponse.class)
        )).thenThrow(new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR));

        galaxyConnectorServiceImpl.getGalaxyInstrumentResponse(bbgCodes, transcodeRequest, List.of("FIN_ID_TICKER", "FIN_ID_ELIOT"));
    }
}
