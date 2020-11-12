module LString =
  struct
    type t = GT.string
           
    class virtual ['inh,'extra,'syn] t_t =
            object inherit  ['inh,'extra,'syn] GT.string_t end
            
    let gcata_t = GT.gcata_string
                
    class ['extra_t] show_t_t fself_t =
      object
        inherit  [unit,'extra_t,string] t_t
        constraint 'extra_t = t
        inherit  ((['extra_t] GT.show_string_t) fself_t)
      end
      
    let rec show_t () subj = GT.show GT.string subj
                           
    let t =
      {
        GT.gcata = gcata_t;
        GT.fix = (fun eta -> GT.transform_gc gcata_t eta);
        GT.plugins = (object method show subj = show_t () subj end)
      }
      
    let show_t subj = show_t () subj
                    
    type ground = t
                
    class virtual ['inh,'extra,'syn] ground_t =
            object inherit  ['inh,'extra,'syn] t_t end
            
    let gcata_ground = gcata_t
                     
    class ['extra_ground] show_ground_t fself_ground =
      object
        inherit  [unit,'extra_ground,string] ground_t
        constraint 'extra_ground = ground
        inherit  ((['extra_ground] show_t_t) fself_ground)
      end
      
    let rec show_ground () subj = GT.show t subj
                                
    let ground =
      {
        GT.gcata = gcata_ground;
        GT.fix = (fun eta -> GT.transform_gc gcata_ground eta);
        GT.plugins = (object method show subj = show_ground () subj end)
      }
      
    let show_ground subj = show_ground () subj
                         
    type logic = t OCanren.logic
               
    class virtual ['inh,'extra,'syn] logic_t =
            object inherit  [t,t,t,'inh,'extra,'syn] OCanren.logic_t end
            
    let gcata_logic = OCanren.gcata_logic
                    
    class ['extra_logic] show_logic_t fself_logic =
      object
        inherit  [unit,'extra_logic,string] logic_t
        constraint 'extra_logic = logic
        inherit  (([t,'extra_logic] OCanren.show_logic_t)
          (fun () -> fun subj -> GT.show t subj) fself_logic)
      end
      
    let rec show_logic () subj =
      GT.show OCanren.logic ((fun () -> fun subj -> GT.show t subj) ()) subj
      
    let logic =
      {
        GT.gcata = gcata_logic;
        GT.fix = (fun eta -> GT.transform_gc gcata_logic eta);
        GT.plugins = (object method show subj = show_logic () subj end)
      }
      
    let show_logic subj = show_logic () subj
                        
    type groundi = (ground, logic) injected
  end
