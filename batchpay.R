######## Project:      Batch Payment for Incentivized Experiments
######## Written by:   Rima-Maria Rahal
######## Last changed: 22.10.2020
######## License:      CC-BY-SA
######## R Version:    4.0.2

library(gdata)

### read in the data (don't forget to change this to match your file name)
### you need an excel sheet that has the following columns:
### name (first and last name)
### iban (obvious)
### total (amount to be transferred)
### reason (reason for paying)

data <- read.xls(xls = "filename.xlsx", sheet = "PAY1", header = TRUE)

data$name<-as.character(data$name)
data$total<-as.character(data$total)
data$iban<-as.character(data$iban)
data$reason<-as.character(data$reason)

### define variable lines
Nm1 <- "Your Name" #name of the sender
IBAN <- "DE00000000000000000000" #iban of the sender
BIC <- "DDDDDDDDDDD" #bic of the sender
NbOfTxs1 <- "15" #how many transfers are you making? (my bank can do 15 at a time)
filename <- "yourfile" #what should the output file be called?


### define more variable lines, these never mattered / caused problems when I made transfers, so I stopped changing them
MsgId <- "2020-04-11-11111" #give your transfer some kind of billing id number, needs to have a format like this 
CreDtTm <- "2020-03-11T11:30:01.000Z" #give your transfer some kind of billing date, needs to have a format like this 
CtrlSum1 <- "240" #what's the total amount you're transferring
PmtInfId <- "2020-04-11-11111_01" #again some kind of billing id number, needs to have a format like this 
ReqdExctnDt <- "2020-04-11" #by when should the payment be made? needs to have a format like this 
NbOfTxs2 <- NbOfTxs1 
CtrlSum2 <- CtrlSum1 
Nm2 <- Nm1

### write some necessary standard text (don't change this)
# ------------- header
pre_MsgId <- "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
<Document 
    xmlns=\"urn:iso:std:iso:20022:tech:xsd:pain.001.003.03\"
    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    xsi:schemaLocation=\"urn:iso:std:iso:20022:tech:xsd:pain.001.003.03 pain.001.003.03.xsd\">
 <CstmrCdtTrfInitn>
   <GrpHdr>
     <MsgId>"

pre_CreDtTm <- "</MsgId>
     <CreDtTm>"

pre_NbOfTxs1 <- "</CreDtTm>
     <NbOfTxs>"

pre_CtrlSum1 <- "</NbOfTxs>
     <CtrlSum>"

pre_Nm1 <- "</CtrlSum>
     <InitgPty><Nm>"

pre_PmtInfId <- "</Nm></InitgPty>
  </GrpHdr>
   <PmtInf>
     <PmtInfId>"

pre_NbOfTxs2 <- "</PmtInfId>
     <PmtMtd>TRF</PmtMtd>
     <BtchBookg>true</BtchBookg>
     <NbOfTxs>"

pre_CtrlSum2 <- "</NbOfTxs>
     <CtrlSum>"

pre_ReqdExtnDt <- "</CtrlSum>
     <PmtTpInf>
        <SvcLvl>
            <InstrPrty>NORM</InstrPrty>
            <Cd>SEPA</Cd>
        </SvcLvl>
     </PmtTpInf>
     <ReqdExctnDt>"

pre_Nm2 <- "</ReqdExctnDt>
     <Dbtr><Nm>"

pre_IBAN <- "</Nm></Dbtr>
     <DbtrAcct><Id><IBAN>"

pre_BIC <- "</IBAN></Id></DbtrAcct>
     <DbtrAgt><FinInstnId><BIC>"

pre_body <- "</BIC></FinInstnId></DbtrAgt>
     <ChrgBr>SLEV</ChrgBr>


      "
#---------- body 

pre_amount <- "<CdtTrfTxInf>
  <PmtId><EndToEndId>NOTPROVIDED</EndToEndId></PmtId>
  <Amt><InstdAmt Ccy=\"EUR\">"

pre_name <- "</InstdAmt></Amt>
       <Cdtr><Nm>"

pre_iban <- "</Nm></Cdtr>
       <CdtrAcct><Id><IBAN>"

pre_reason <- "</IBAN></Id></CdtrAcct>
       <RmtInf><Ustrd>"

end <- "</Ustrd></RmtInf>
      </CdtTrfTxInf>
      
      "

#------------- footer
tail <- "      

      
   </PmtInf>
 </CstmrCdtTrfInitn>
</Document>"


### in case you need to do this in several small batches, I've written a loop here that you can restart 
### multiple times to generate several files


### define row number to start from 
start <- 1

file <- paste("filename", start, ".xml", sep="")

### write file header -- don't change this
cat(c(pre_MsgId, MsgId, pre_CreDtTm, CreDtTm, pre_NbOfTxs1, NbOfTxs1, pre_CtrlSum1, CtrlSum1, pre_Nm1, 
      Nm1, pre_PmtInfId, PmtInfId, pre_NbOfTxs2, NbOfTxs2, pre_CtrlSum2, CtrlSum2, 
      pre_ReqdExtnDt, ReqdExctnDt, pre_Nm2, Nm2, pre_IBAN, IBAN, pre_BIC, BIC, pre_body), file=file, append = FALSE, sep = "")

### write file body -- with a loop that takes into account the max number of transfers you can do
cat(c(pre_amount,data$total[start],pre_name,data$name[start],pre_iban,data$iban[start], 
      pre_reason,data$reason[start],end), file=file, append = TRUE, sep = "")
for(i in (start+1):(start+as.numeric(NbOfTxs1)-1)){
  print(i)
  cat(c(pre_amount, data$total[i], pre_name, data$name[i], pre_iban, data$iban[i], 
        pre_reason, data$reason[i], end), file=file, append = TRUE, sep = "")
}

### write file footer -- don't change this
cat(c(tail), file=file, append = TRUE, sep = "")
