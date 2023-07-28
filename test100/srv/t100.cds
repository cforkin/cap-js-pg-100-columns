using {T100 as t100 } from '../db/schema';

service T100Service {
  @readonly entity T100 as projection on t100;
};
