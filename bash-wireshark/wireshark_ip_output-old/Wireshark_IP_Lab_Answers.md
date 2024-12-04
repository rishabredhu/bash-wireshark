
# Wireshark Lab: IP v8.0 Answers

## Q1: What is the IP address of your computer?
The IP address of the computer is **192.168.1.90**.

## Q2: Within the IP packet header, what is the value in the upper layer protocol field?
The value in the upper layer protocol field is **ICMP (1)**.

## Q3: How many bytes are in the IP header? How many bytes are in the payload of the IP datagram? Explain.
The IP header is 20 bytes. The payload varies depending on the specific packet. For example, the total length for certain packets is 56 bytes, implying a payload of **36 bytes**.

### Explanation:
The payload length can be calculated by subtracting the IP header length from the total length.

## Q4: Has this IP datagram been fragmented? Explain.
Yes, the IP datagram has been fragmented. This is evident from the "More Fragments" flag in the IP header being set and the fragmentation offset field containing a non-zero value.

## Q5: Which fields in the IP datagram always change from one datagram to the next within this series of ICMP messages sent by your computer?
- **Identification** field changes for each datagram.
- **TTL** field decreases as packets traverse the network.

## Q6: Which fields stay constant? Which of the fields must stay constant? Which fields must change? Why?
### Constant Fields:
- **Source IP address**
- **Destination IP address**
### Fields That Change:
- **Identification** (to uniquely identify fragments of the same datagram).
- **TTL** (decreases at each hop to prevent infinite looping).
### Explanation:
Constant fields represent the communication endpoints, while changing fields ensure proper routing and fragmentation handling.

## Q7: Describe the pattern you see in the values in the Identification field of the IP datagram.
The **Identification** field increases incrementally with each new datagram sent.

## Q8: What is the value in the Identification field and the TTL field?
- **Identification**: 41510 (example value from the first ICMP packet).
- **TTL**: 1 (indicating this is the first hop).

## Q9: Do these values remain unchanged for all of the ICMP TTL-exceeded replies sent to your computer by the nearest (first hop) router? Why?
No, the **TTL** value changes for different routers as it reflects the number of hops. The **Identification** value remains constant for a specific datagram but changes for different datagrams.

## Q10: Has that message been fragmented across more than one IP datagram?
Yes, when the packet size is increased to 2000 bytes, the message is fragmented.

## Q11: What information in the IP header indicates that the datagram has been fragmented?
- **Flags**: The "More Fragments" flag is set.
- **Fragment Offset**: Indicates the position of the fragment in the original datagram.

### Length of the first fragment:
The total length is **1500 bytes**, which is the Ethernet MTU.

## Q12: What information in the IP header indicates whether this is the first fragment versus a latter fragment?
- The first fragment has a **Fragment Offset** of 0.
- Subsequent fragments have non-zero **Fragment Offset** values.

### More fragments:
The "More Fragments" flag is set for all fragments except the last one.

## Q13: What fields change in the IP header between the first and second fragment?
- **Fragment Offset**
- **Total Length**
- **Flags** (More Fragments flag may change).

## Q14: How many fragments were created from the original datagram?
For a 3500-byte datagram, **3 fragments** were created.

## Q15: What fields change in the IP header among the fragments?
- **Fragment Offset**
- **Total Length**
- **Flags**

