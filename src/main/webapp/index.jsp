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
package sgcib.tsf.dragonBook.services;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringRunner;
import sgcib.tsf.dragonBook.DragonBookApplication;
import sgcib.tsf.dragonBook.model.xone.basket.compo.*;
import sgcib.tsf.dragonBook.services.exception.CustomException;
import sgcib.tsf.dragonBook.services.exception.DealNotFoundException;
import sgcib.tsf.dragonBook.services.xone.XoneBookDealsImpl;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@SpringBootTest(classes = DragonBookApplication.class)
@ContextConfiguration
@ActiveProfiles("test")
@RunWith(SpringRunner.class)
public class XoneBookDealsImplTest {

    @Autowired
    private XoneBookDealsImpl xoneBookDealsImpl;

    @Mock
    private RestTemplate restTemplateMock;

    @Before
    public void setup() {
        xoneBookDealsImpl = new XoneBookDealsImpl(restTemplateMock);
    }

    @Test
    public void testGetETagWithNewRateFixingTrue() {
        XoneGetBasketDetails uriResponse = buildXoneGetBasketDetails("2024-04-10");
        HttpHeaders headers = new HttpHeaders();
        headers.add("eTag", "qwadfeydwtdwega_");
        XoneDeals basketCompo = buildBasketCompo();
        ResponseEntity<XoneGetBasketDetails> response = new ResponseEntity<>(uriResponse, headers, HttpStatus.OK);

        when(restTemplateMock.exchange(anyString(), eq(HttpMethod.GET), any(), eq(XoneGetBasketDetails.class), anyMap())).thenReturn(response);

        Boolean result = xoneBookDealsImpl.getETag(basketCompo, response, true);

        assertNotNull(result);
        assertTrue(basketCompo.getEventInfo().getObserveNewRateFixing());
    }

    @Test
    public void testGetETagWithNewRateFixingFalse() {
        XoneGetBasketDetails uriResponse = buildXoneGetBasketDetails("2024-04-08");
        HttpHeaders headers = new HttpHeaders();
        headers.add("eTag", "qwadfeydwt.dwega_");
        XoneDeals basketCompo = buildBasketCompo();
        ResponseEntity<XoneGetBasketDetails> response = new ResponseEntity<>(uriResponse, headers, HttpStatus.OK);

        when(restTemplateMock.exchange(anyString(), eq(HttpMethod.GET), any(), eq(XoneGetBasketDetails.class), anyMap())).thenReturn(response);

        Boolean result = xoneBookDealsImpl.getETag(basketCompo, response, true);

        assertNotNull(result);
        assertFalse(basketCompo.getEventInfo().getObserveNewRateFixing());
    }

    @Test
    public void testUpdateEvents() {
        String tradeRef = "TRADE123";
        XoneDeals xoneRequest = buildBasketCompo();
        XoneUpdateEventsResponse expectedResponse = new XoneUpdateEventsResponse();

        HttpHeaders headers = new HttpHeaders();
        headers.add("If-Match", "qwadfeydwtdwega_");
        HttpEntity<Object> request = new HttpEntity<>(xoneRequest, headers);

        ResponseEntity<XoneUpdateEventsResponse> responseEntity = new ResponseEntity<>(expectedResponse, HttpStatus.OK);

        when(restTemplateMock.exchange(anyString(), eq(HttpMethod.POST), eq(request), eq(XoneUpdateEventsResponse.class), anyMap())).thenReturn(responseEntity);

        XoneUpdateEventsResponse actualResponse = xoneBookDealsImpl.updateEvents(xoneRequest, tradeRef, true);

        assertNotNull(actualResponse);
        assertEquals(expectedResponse, actualResponse);
    }

    @Test(expected = RuntimeException.class)
    public void testUpdateEventsServerError() {
        String tradeRef = "TRADE123";
        XoneDeals xoneRequest = buildBasketCompo();

        HttpHeaders headers = new HttpHeaders();
        headers.add("If-Match", "qwadfeydwtdwega_");
        HttpEntity<Object> request = new HttpEntity<>(xoneRequest, headers);

        when(restTemplateMock.exchange(anyString(), eq(HttpMethod.POST), eq(request), eq(XoneUpdateEventsResponse.class), anyMap()))
                .thenThrow(HttpServerErrorException.class);

        xoneBookDealsImpl.updateEvents(xoneRequest, tradeRef, true);
    }

    @Test(expected = DealNotFoundException.class)
    public void testGetTradeDealNotFound() throws DealNotFoundException {
        String tradeRef = "TRADE123";
        XoneDeals xoneRequest = buildBasketCompo();

        when(restTemplateMock.exchange(anyString(), eq(HttpMethod.GET), any(), eq(XoneGetBasketDetails.class), anyMap()))
                .thenThrow(new DealNotFoundException("Deal not found"));

        xoneBookDealsImpl.getTrade(tradeRef, xoneRequest, true);
    }

    @Test
    public void testBookDeals() {
        XoneDeals lnBDatum = buildBasketCompo();
        XoneUpdateEventsResponse expectedResponse = new XoneUpdateEventsResponse();
        HttpEntity<Object> request = new HttpEntity<>(lnBDatum);

        ResponseEntity<XoneUpdateEventsResponse> responseEntity = new ResponseEntity<>(expectedResponse, HttpStatus.OK);

        when(restTemplateMock.exchange(anyString(), eq(HttpMethod.POST), eq(request), eq(XoneUpdateEventsResponse.class))).thenReturn(responseEntity);

        XoneUpdateEventsResponse actualResponse = xoneBookDealsImpl.bookDeals(lnBDatum);

        assertNotNull(actualResponse);
        assertEquals(expectedResponse, actualResponse);
    }

    @Test(expected = CustomException.class)
    public void testBookDealsServerError() {
        XoneDeals lnBDatum = buildBasketCompo();
        HttpEntity<Object> request = new HttpEntity<>(lnBDatum);

        when(restTemplateMock.exchange(anyString(), eq(HttpMethod.POST), eq(request), eq(XoneUpdateEventsResponse.class)))
                .thenThrow(HttpServerErrorException.class);

        xoneBookDealsImpl.bookDeals(lnBDatum);
    }

    private XoneDeals buildBasketCompo() {
        List<BasketComponentsChanges> changesList = new ArrayList<>();
        List<Fixings> fixingsList = new ArrayList<>();
        Fixings fixings = Fixings.builder().fixingType("Stock").fixingValue(4.35).fixingName("ABC.LN").fxRateValue(null).estimated(false).manual(true).build();
        fixingsList.add(fixings);
        BasketComponentsChanges basketChange = BasketComponentsChanges.builder().modificationType("Modified").underlyingName("ABC.LN").deltaPonderation(123123).build();
        changesList.add(basketChange);
        XoneEventInfo eventInfo = XoneEventInfo.builder().comments(null).eventDate("2024-04-10").valueDate("2024-04-11").owner("ABCDE").confirmationToBeChecked(false).resetMode("FIFO").basketRemodellingMode("Standard").fixings(fixingsList).basketComponentsChanges(changesList).observeNewRateFixing(true).dividendCurrentFlowMode("AccruedCouponWithSamePaymentDate").equityCurrentFlowMode("AccruedCouponWithEffectivePaymentDate").rateCurrentFlowMode("AccruedCouponWithEffectivePaymentDate").build();
        return XoneDeals.builder().eventInfo(eventInfo).actions("BasketIncreaseDecrease").build();
    }

    private XoneGetBasketDetails buildXoneGetBasketDetails(String date) {
        XoneGetBasketDetails basketDetails = new XoneGetBasketDetails();
        XoneProductInfo productInfo = new XoneProductInfo();
        XoneReturnLeg returnLeg = new XoneReturnLeg();
        ResetFlows flows = ResetFlows.builder().flowType("performance").startDate(date).build();
        List<ResetFlows> flowsList = new ArrayList<>();
        flowsList.add(flows);
        returnLeg.setFlows(flowsList);
        productInfo.setReturnLeg(returnLeg);
        basketDetails.setProductInfo(productInfo);
        return basketDetails;
    }
}
