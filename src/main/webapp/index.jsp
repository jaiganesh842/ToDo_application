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

package sgcib.tsf.dragonBook.services.xone;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;
import sgcib.tsf.dragonBook.model.xone.basketcompo.*;
import sgcib.tsf.dragonBook.services.exception.CustomException;
import sgcib.tsf.dragonBook.services.exception.DealNotFoundException;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static org.junit.Assert.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;

@RunWith(MockitoJUnitRunner.class)
public class XoneBookDealsImplTest {

    @InjectMocks
    private XoneBookDealsImpl xoneBookDealsImpl;

    @Mock
    private RestTemplate restTemplate;

    @Test
    public void testUpdateEvents_Success() {
        XoneDeals xoneRequest = buildXoneDeals();
        String tradeRef = "TRADE123";
        Boolean basketCompo = true;
        XoneUpdateEventsResponse expectedResponse = buildXoneUpdateEventsResponse();

        when(restTemplate.exchange(anyString(), any(), any(), eq(XoneUpdateEventsResponse.class), anyMap()))
                .thenReturn(new ResponseEntity<>(expectedResponse, HttpStatus.OK));

        XoneUpdateEventsResponse actualResponse = xoneBookDealsImpl.updateEvents(xoneRequest, tradeRef, basketCompo);

        assertNotNull(actualResponse);
        assertEquals(expectedResponse, actualResponse);
    }

    @Test(expected = RuntimeException.class)
    public void testUpdateEvents_HttpServerErrorException() {
        XoneDeals xoneRequest = buildXoneDeals();
        String tradeRef = "TRADE123";
        Boolean basketCompo = true;

        when(restTemplate.exchange(anyString(), any(), any(), eq(XoneUpdateEventsResponse.class), anyMap()))
                .thenThrow(new CustomException("Simulated HTTP Server Error"));

        xoneBookDealsImpl.updateEvents(xoneRequest, tradeRef, basketCompo);
    }

    @Test(expected = DealNotFoundException.class)
    public void testUpdateEvents_DealNotFoundException() {
        XoneDeals xoneRequest = buildXoneDeals();
        String tradeRef = "TRADE123";
        Boolean basketCompo = true;

        when(restTemplate.exchange(anyString(), any(), any(), eq(XoneUpdateEventsResponse.class), anyMap()))
                .thenThrow(new DealNotFoundException("Simulated Deal Not Found"));

        xoneBookDealsImpl.updateEvents(xoneRequest, tradeRef, basketCompo);
    }

    @Test
    public void testBookDeals_Success() {
        XoneDeals lnBDatum = buildXoneDeals();
        XoneUpdateEventsResponse expectedResponse = buildXoneUpdateEventsResponse();

        when(restTemplate.exchange(anyString(), any(), any(), eq(XoneUpdateEventsResponse.class)))
                .thenReturn(new ResponseEntity<>(expectedResponse, HttpStatus.OK));

        XoneUpdateEventsResponse actualResponse = xoneBookDealsImpl.bookDeals(lnBDatum);

        assertNotNull(actualResponse);
        assertEquals(expectedResponse, actualResponse);
    }

    @Test(expected = CustomException.class)
    public void testBookDeals_HttpServerErrorException() {
        XoneDeals lnBDatum = buildXoneDeals();

        when(restTemplate.exchange(anyString(), any(), any(), eq(XoneUpdateEventsResponse.class)))
                .thenThrow(new CustomException("Simulated HTTP Server Error"));

        xoneBookDealsImpl.bookDeals(lnBDatum);
    }

    @Test
    public void testGetTrade_Success() {
        String tradeRef = "TRADE123";
        XoneDeals basketCompoRequest = buildXoneDeals();
        Boolean basketCompo = true;
        XoneGetBasketDetails expectedResponse = buildXoneGetBasketDetails("2024-06-10");

        when(restTemplate.exchange(anyString(), any(), eq(null), eq(XoneGetBasketDetails.class), anyMap()))
                .thenReturn(new ResponseEntity<>(expectedResponse, HttpStatus.OK));

        String actualETag = xoneBookDealsImpl.getTrade(tradeRef, basketCompoRequest, basketCompo);

        assertNotNull(actualETag);
        assertEquals("qwadfeydwtdwega_", actualETag); // Assuming this is the expected ETag value
    }

    @Test(expected = DealNotFoundException.class)
    public void testGetTrade_DealNotFoundException() {
        String tradeRef = "TRADE123";
        XoneDeals basketCompoRequest = buildXoneDeals();
        Boolean basketCompo = true;

        when(restTemplate.exchange(anyString(), any(), eq(null), eq(XoneGetBasketDetails.class), anyMap()))
                .thenThrow(new DealNotFoundException("Simulated Deal Not Found"));

        xoneBookDealsImpl.getTrade(tradeRef, basketCompoRequest, basketCompo);
    }

    private XoneDeals buildXoneDeals() {
        // Create sample data for XoneEventInfo
        XoneEventInfo eventInfo = XoneEventInfo.builder()
                .comments("Sample comments")
                .eventDate("2024-06-10")
                .valueDate("2024-06-11")
                .owner("SampleOwner")
                .confirmationToBeChecked(false)
                .resetMode("FIFO")
                .basketRemodellingMode("Standard")
                .observeNewRateFixing(true)
                .dividendCurrentFlowMode("AccruedCouponWithSamePaymentDate")
                .equityCurrentFlowMode("AccruedCouponwithEffectivePaymentDate")
                .rateCurrentFlowMode("AccruedCouponwithEffectivePaymentDate")
                .build();

        // Create sample data for XoneProductInfo
        XoneProductInfo productInfo = XoneProductInfo.builder()
                .way("SampleWay")
                .startDate("2024-06-10")
                .headerType("SampleHeaderType")
                .headerId("SampleHeaderId")
                .dealMaturityType("SampleDealMaturityType")
                .theoreticalEndDate("2024-06-20")
                .billingFrequency("SampleBillingFrequency")
                .currency("USD")
                .callableForDiv(true)
                .isFixedPrice(false)
                .backComment("SampleBackComment")
                .settlementComment("SampleSettlementComment")
                .confirmationComment("SampleConfirmationComment")
                .desiderata(XoneDesiderata.builder().desiderataCode("SampleDesiderataCode").build())
                .build();

        // Create sample data for XoneReturnLeg
        ResetFlows resetFlow = ResetFlows.builder().flowType("Performance").startDate("2024-06-10").build();
        List<ResetFlows> flows = Collections.singletonList(resetFlow);
        XoneReturnLeg returnLeg = XoneReturnLeg.builder().flows(flows).build();

        // Create sample data for XoneDeals
        return XoneDeals.builder()
                .instrumentName("SampleInstrumentName")
                .instrumentContractName("SampleInstrumentContractName
                                .instrumentContractName("SampleInstrumentContractName")
                .issuerShortName("SampleIssuerShortName")
                .lnbProductInfo(productInfo)
                .events(Collections.singletonList(eventInfo))
                .returnLegs(Collections.singletonList(returnLeg))
                .build();
    }

    private XoneUpdateEventsResponse buildXoneUpdateEventsResponse() {
        return XoneUpdateEventsResponse.builder()
                .status("Success")
                .message("Events updated successfully")
                .build();
    }

    private XoneGetBasketDetails buildXoneGetBasketDetails(String lastModifiedDate) {
        return XoneGetBasketDetails.builder()
                .basketStatus("Active")
                .lastModifiedDate(lastModifiedDate)
                .build();
    }

    @Test
    public void testBookDeals_NullLnBDatum() {
        XoneDeals lnBDatum = null;

        try {
            xoneBookDealsImpl.bookDeals(lnBDatum);
            fail("Expected an IllegalArgumentException to be thrown");
        } catch (IllegalArgumentException e) {
            assertEquals("lnBDatum must not be null", e.getMessage());
        }
    }

    @Test
    public void testBookDeals_EmptyInstrumentName() {
        XoneDeals lnBDatum = buildXoneDeals();
        lnBDatum.setInstrumentName("");

        try {
            xoneBookDealsImpl.bookDeals(lnBDatum);
            fail("Expected a CustomException to be thrown");
        } catch (CustomException e) {
            assertEquals("Instrument name cannot be empty", e.getMessage());
        }
    }

    @Test
    public void testUpdateEvents_NullXoneRequest() {
        XoneDeals xoneRequest = null;
        String tradeRef = "TRADE123";
        Boolean basketCompo = true;

        try {
            xoneBookDealsImpl.updateEvents(xoneRequest, tradeRef, basketCompo);
            fail("Expected an IllegalArgumentException to be thrown");
        } catch (IllegalArgumentException e) {
            assertEquals("xoneRequest must not be null", e.getMessage());
        }
    }

    @Test
    public void testUpdateEvents_EmptyTradeRef() {
        XoneDeals xoneRequest = buildXoneDeals();
        String tradeRef = "";
        Boolean basketCompo = true;

        try {
            xoneBookDealsImpl.updateEvents(xoneRequest, tradeRef, basketCompo);
            fail("Expected a CustomException to be thrown");
        } catch (CustomException e) {
            assertEquals("Trade reference cannot be empty", e.getMessage());
        }
    }

    @Test
    public void testGetTrade_NullTradeRef() {
        String tradeRef = null;
        XoneDeals basketCompoRequest = buildXoneDeals();
        Boolean basketCompo = true;

        try {
            xoneBookDealsImpl.getTrade(tradeRef, basketCompoRequest, basketCompo);
            fail("Expected an IllegalArgumentException to be thrown");
        } catch (IllegalArgumentException e) {
            assertEquals("tradeRef must not be null", e.getMessage());
        }
    }

    @Test
    public void testGetTrade_EmptyTradeRef() {
        String tradeRef = "";
        XoneDeals basketCompoRequest = buildXoneDeals();
        Boolean basketCompo = true;

        try {
            xoneBookDealsImpl.getTrade(tradeRef, basketCompoRequest, basketCompo);
            fail("Expected a CustomException to be thrown");
        } catch (CustomException e) {
            assertEquals("Trade reference cannot be empty", e.getMessage());
        }
    }

    @Test
    public void testGetTrade_NullBasketCompoRequest() {
        String tradeRef = "TRADE123";
        XoneDeals basketCompoRequest = null;
        Boolean basketCompo = true;

        try {
            xoneBookDealsImpl.getTrade(tradeRef, basketCompoRequest, basketCompo);
            fail("Expected an IllegalArgumentException to be thrown");
        } catch (IllegalArgumentException e) {
            assertEquals("basketCompoRequest must not be null", e.getMessage());
        }
    }
}
