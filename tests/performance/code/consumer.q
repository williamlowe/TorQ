// Main consumer process code

// Single update UPD
.consumer.upd.single:{[t;x]
  now:.z.p;
  res:delete sym from $[0h~type x;flip .consumer.singlecols!x;x];
  res:update consumertime:now,feedtotp:time-feedtime,tptoconsumer:now-time,feedtoconsumer:now-feedtime,batching:.consumer.batching,pubmode:`single from res;
  `.consumer.results upsert res;
 };

// Bulk update UPD
.consumer.upd.bulk:{[t;x]
  now:.z.p;
  res:select time,feedtime from $[0h~type x;.consumer.bulkcols !/: .consumer.getfirstrows flip x;.consumer.getfirstrows x];
  res:update consumertime:now,feedtotp:time-feedtime,tptoconsumer:now-time,feedtoconsumer:now-feedtime,batching:.consumer.batching,pubmode:`bulk from res;
  `.consumer.results upsert res;
 };

// Get first row from each bulk update
.consumer.getfirstrows:{
  x .consumer.bulkrows*til (count x) div .consumer.bulkrows
 };

// Clear results table
.consumer.cleartable:{
  .lg.o[`clear;"Clearing local results table..."];
  delete from `.consumer.results;
 };

// Set up connection management, subscribe to tables and choose the UPD function
.consumer.init:{[mode;batch]
  .proc.loadf first (.Q.opt .z.x)[`config];
  .servers.startup[];
  .consumer.tphandle:.servers.gethandlebytype[$[`vanilla~batch;`tickerplant;`segmentedtickerplant];`any];
  .consumer.batching:batch;
  .consumer.tphandle @/: {(`.u.sub;x;`)} each `singleupd`bulkupd;
  `upd set .consumer.upd[mode];
  };