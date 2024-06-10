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

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.*;
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

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    @Autowired
    private XoneBookDealsImpl xoneBookDealsImpl;

    @Before
    public void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    public void testUpdateEventsSuccess() {
        XoneDeals xoneRequest = buildBasketCompo();
        String tradeRef = "testTradeRef";
        String eTag = "testETag";
        Boolean basketCompo = true;

        when(restTemplate.exchange(anyString(), eq(HttpMethod.POST), any(HttpEntity.class), eq(XoneUpdateEventsResponse.class), anyMap()))
                .thenReturn(new ResponseEntity<>(new XoneUpdateEventsResponse(), HttpStatus.OK));

        doReturn(eTag).when(xoneBookDealsImpl).getTrade(anyString(), any(XoneDeals.class), anyBoolean());

        XoneUpdateEventsResponse response = xoneBookDealsImpl.updateEvents(xoneRequest, tradeRef, basketCompo);

        assertNotNull(response);
        verify(restTemplate, times(1)).exchange(anyString(), eq(HttpMethod.POST), any(HttpEntity.class), eq(XoneUpdateEventsResponse.class), anyMap());
    }

    @Test(expected = RuntimeException.class)
    public void testUpdateEventsHttpServerErrorException() {
        XoneDeals xoneRequest = buildBasketCompo();
        String tradeRef = "testTradeRef";
        Boolean basketCompo = true;

        doThrow(new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR)).when(restTemplate).exchange(anyString(), eq(HttpMethod.POST), any(HttpEntity.class), eq(XoneUpdateEventsResponse.class), anyMap());

        xoneBookDealsImpl.updateEvents(xoneRequest, tradeRef, basketCompo);
    }

    @Test(expected = DealNotFoundException.class)
    public void testUpdateEventsDealNotFoundException() {
        XoneDeals xoneRequest = buildBasketCompo();
        String tradeRef = "testTradeRef";
        Boolean basketCompo = true;

        doThrow(new DealNotFoundException("Deal not found")).when(xoneBookDealsImpl).getTrade(anyString(), any(XoneDeals.class), anyBoolean());

        xoneBookDealsImpl.updateEvents(xoneRequest, tradeRef, basketCompo);
    }

    @Test(expected = CustomException.class)
    public void testUpdateEventsCustomException() {
        XoneDeals xoneRequest = buildBasketCompo();
        String tradeRef = "testTradeRef";
        Boolean basketCompo = true;

        doThrow(new RuntimeException("General exception")).when(restTemplate).exchange(anyString(), eq(HttpMethod.POST), any(HttpEntity.class), eq(XoneUpdateEventsResponse.class), anyMap());

        xoneBookDealsImpl.updateEvents(xoneRequest, tradeRef, basketCompo);
    }

    @Test
    public void testBookDealsSuccess() {
        XoneDeals lnBDatum = buildBasketCompo();

        when(restTemplate.exchange(anyString(), eq(HttpMethod.POST), any(HttpEntity.class), eq(XoneUpdateEventsResponse.class)))
                .thenReturn(new ResponseEntity<>(new XoneUpdateEventsResponse(), HttpStatus.OK));

        XoneUpdateEventsResponse response = xoneBookDealsImpl.bookDeals(lnBDatum);

        assertNotNull(response);
        verify(restTemplate, times(1)).exchange(anyString(), eq(HttpMethod.POST), any(HttpEntity.class), eq(XoneUpdateEventsResponse.class));
    }

    @Test(expected = CustomException.class)
    public void testBookDealsHttpServerErrorException() {
        XoneDeals lnBDatum = buildBasketCompo();

        doThrow(new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR)).when(restTemplate).exchange(anyString(), eq(HttpMethod.POST), any(HttpEntity.class), eq(XoneUpdateEventsResponse.class));

        xoneBookDealsImpl.bookDeals(lnBDatum);
    }

    @Test(expected = CustomException.class)
    public void testBookDealsCustomException() {
        XoneDeals lnBDatum = buildBasketCompo();

        doThrow(new RuntimeException("General exception")).when(restTemplate).exchange(anyString(), eq(HttpMethod.POST), any(HttpEntity.class), eq(XoneUpdateEventsResponse.class));

        xoneBookDealsImpl.bookDeals(lnBDatum);
    }

    @Test
    public void testGetTradeSuccess() throws DealNotFoundException {
        String tradeRef = "testTradeRef";
        XoneDeals basketCompoRequest = buildBasketCompo();
        Boolean basketCompo = true;

        HttpHeaders headers = new HttpHeaders();
        headers.add("eTag", "testETag");

        ResponseEntity<XoneGetBasketDetails> responseEntity = new ResponseEntity<>(new XoneGetBasketDetails(), headers, HttpStatus.OK);

        when(restTemplate.exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(XoneGetBasketDetails.class), anyMap()))
                .thenReturn(responseEntity);

        doReturn(true).when(xoneBookDealsImpl).getETag(any(XoneDeals.class), any(ResponseEntity.class), anyBoolean());

        String eTag = xoneBookDealsImpl.getTrade(tradeRef, basketCompoRequest, basketCompo);

        assertNotNull(eTag);
        assertEquals("testETag", eTag);
    }

    @Test(expected = DealNotFoundException.class)
    public void testGetTradeDealNotFoundException() throws DealNotFoundException {
        String tradeRef = "testTradeRef";
        XoneDeals basketCompoRequest = buildBasketCompo();
        Boolean basketCompo = true;

        doThrow(new RuntimeException("Cannot load trade")).when(restTemplate).exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(XoneGetBasketDetails.class), anyMap());

        xoneBookDealsImpl.getTrade(tradeRef, basketCompoRequest, basketCompo);
    }

    @Test(expected = RuntimeException.class)
    public void testGetTradeRuntimeException() throws DealNotFoundException {
        String tradeRef = "testTradeRef";
        XoneDeals basketCompoRequest = buildBasketCompo();
        Boolean basketCompo = true;

        doThrow(new RuntimeException("General exception")).when(restTemplate).exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(XoneGetBasketDetails.class), anyMap());

        xoneBookDealsImpl.getTrade(tradeRef, basketCompoRequest, basketCompo);
    }

    @Test
    public void testGetETagWithNewRateFixingTrue() {
        XoneGetBasketDetails uriResponse = buildXoneGetBasketDetails("2024-04-10");
        HttpHeaders headers = new HttpHeaders();
        headers.add("eTag", "qwadfeydwtdwega_");
        XoneDeals basketCompo = buildBasketCompo();
        ResponseEntity<XoneGetBasketDetails> response = new ResponseEntity<>(uriResponse, headers, HttpStatus.OK);
        Boolean result = xoneBookDealsImpl.getETag(basketCompo, response, true);
        assertNotNull(result);
        assertTrue(result);
    }

    @Test
    public void testGetETagWithNewRateFixingFalse() {
        XoneGetBasketDetails uriResponse = buildXoneGetBasketDetails("2024-04-08");
        HttpHeaders headers = new HttpHeaders();
        headers.add("eTag", "qwadfeydwtdwega_");
        XoneDeals basketCompo = buildBasketCompo();
        ResponseEntity<XoneGetBasketDetails> response = new ResponseEntity<>(uriResponse, headers, HttpStatus.OK);
        Boolean result = xoneBookDealsImpl.getETag(basketCompo, response, true);
        assertNotNull(result);
        assertFalse(basketCompo.getEventInfo().getObserveNewRateFixing());
    }

    private XoneDeals buildBasketCompo() {
        List<BasketComponentsChanges> changesList = new ArrayList<>();
        List<Fixings> fixingsList = new ArrayList<>();
        Fixings fixings = Fixings.builder()
                .fixingType("Stock")
                .fixingValue(4.35)
                .fixingName("ABC.LN")
                .fxRateValue(null)
                .estimated(false)
                .manual(true)
                .build();
        fixingsList.add(fixings);
        BasketComponentsChanges basketChange = BasketComponentsChanges.builder()
                .modificationType("Modified")
                .underlyingName("ABC.LN")
                .deltaPonderation(123123)
                .build();
        changesList.add(basketChange);
        XoneEventInfo eventInfo = XoneEventInfo.builder()
                .comments(null)
                .eventDate("2024-04-10")
                .valueDate("2024-04-11")
                .owner("ABCDE")
                .confirmationToBeChecked(false)
                .resetMode("FIFO")
                .basketRemodellingMode("Standard")
                .fixings(fixingsList)
                .basketComponentsChanges(changesList)
                .observeNewRateFixing(true)
                .dividendCurrentFlowMode("AccruedCouponWithSamePaymentDate")
                .equityCurrentFlowMode("AccruedCouponWithEffectivePaymentDate")
                .rateCurrentFlowMode("AccruedCouponWithEffectivePaymentDate")
                .build();
        return XoneDeals.builder()
                .eventInfo(eventInfo)
                .actions("BasketIncreaseDecrease")
                .build();
    }

    private XoneGetBasketDetails buildXoneGetBasketDetails(String date) {
        XoneGetBasketDetails basketDetails = new XoneGetBasketDetails();
        XoneProductInfo productInfo = new XoneProductInfo();
        XoneReturnLeg returnLeg = new XoneReturnLeg();
        ResetFlows flows = ResetFlows.builder()
                .flowType("performance")
                .startDate(date)
                .build();
        List<ResetFlows> flowsList = new ArrayList<>();
        flowsList.add(flows);
        returnLeg.setFlows(flowsList);
        productInfo.setReturnLeg(returnLeg);
        basketDetails.setProductInfo(productInfo);
        return basketDetails;
    }
}
