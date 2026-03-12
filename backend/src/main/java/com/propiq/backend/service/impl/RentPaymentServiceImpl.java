package com.propiq.backend.service.impl;

import com.propiq.backend.dto.request.RentPaymentRequest;
import com.propiq.backend.entity.Lease;
import com.propiq.backend.entity.RentPayment;
import com.propiq.backend.enums.RentStatus;
import com.propiq.backend.repository.LeaseRepository;
import com.propiq.backend.repository.RentPaymentRepository;
import com.propiq.backend.service.RentPaymentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class RentPaymentServiceImpl implements RentPaymentService {

    private final RentPaymentRepository rentPaymentRepository;
    private final LeaseRepository leaseRepository;

    private static final BigDecimal TDS_THRESHOLD = new BigDecimal("50000");
    private static final BigDecimal TDS_RATE = new BigDecimal("0.10");
    private static final BigDecimal LATE_FEE_PER_DAY = new BigDecimal("100");

    @Override
    public RentPayment recordPayment(RentPaymentRequest req, String ownerEmail) {
        Lease lease = leaseRepository.findById(req.getLeaseId())
                .orElseThrow(() -> new RuntimeException("Lease not found"));

        if (rentPaymentRepository.existsByLeaseIdAndMonthYear(req.getLeaseId(), req.getMonthYear()))
            throw new RuntimeException("Payment already recorded for " + req.getMonthYear());

        LocalDate paidDate = req.getPaidDate() != null ? req.getPaidDate() : LocalDate.now();
        BigDecimal amountPaid = req.getAmountPaid();
        BigDecimal lateFee = BigDecimal.ZERO;
        BigDecimal tdsAmount = BigDecimal.ZERO;
        boolean tdsApplicable = false;

        // Late fee calculation
        int dueDay = lease.getDueDay();
        if (paidDate.getDayOfMonth() > dueDay) {
            int daysLate = paidDate.getDayOfMonth() - dueDay;
            lateFee = LATE_FEE_PER_DAY.multiply(BigDecimal.valueOf(daysLate));
            log.info("Late fee applied: â‚¹{} ({} days late)", lateFee, daysLate);
        }

        // TDS calculation - Section 194-IB
        if (lease.getMonthlyRent().compareTo(TDS_THRESHOLD) > 0) {
            tdsApplicable = true;
            tdsAmount = amountPaid.multiply(TDS_RATE);
            log.warn("TDS ALERT: Rent â‚¹{} exceeds â‚¹50,000. TDS applicable: â‚¹{} (Section 194-IB)",
                    lease.getMonthlyRent(), tdsAmount);
        }

        RentPayment payment = RentPayment.builder()
                .lease(lease).monthYear(req.getMonthYear())
                .amountDue(lease.getMonthlyRent()).amountPaid(amountPaid)
                .lateFee(lateFee).tdsApplicable(tdsApplicable).tdsAmount(tdsAmount)
                .paidDate(paidDate).status(RentStatus.PAID)
                .build();

        return rentPaymentRepository.save(payment);
    }

    @Override
    public List<RentPayment> getPaymentsForLease(Long leaseId, String ownerEmail) {
        return rentPaymentRepository.findByLeaseId(leaseId);
    }
}